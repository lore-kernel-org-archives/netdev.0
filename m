From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] net: filter: initialize A and X registers
Date: Wed, 23 Apr 2014 12:52:35 -0400 (EDT)
Message-ID: <20140423.125235.1748012189632512309.davem@davemloft.net>
References: <20140422.235745.1219194947074686642.davem@davemloft.net>
	<CAMEtUux=mOyZkfxMWi3eA01TvmJrfJpeBpGcHvheptcckA=dzQ@mail.gmail.com>
	<5357659E.1070807@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ast@plumgrid.com, netdev@vger.kernel.org
To: dborkman@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49721 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756629AbaDWQwh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Apr 2014 12:52:37 -0400
In-Reply-To: <5357659E.1070807@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <dborkman@redhat.com>
Date: Wed, 23 Apr 2014 09:02:54 +0200

> On 04/23/2014 06:59 AM, Alexei Starovoitov wrote:
>> On Tue, Apr 22, 2014 at 8:57 PM, David Miller <davem@davemloft.net>
>> wrote:
>>> From: Alexei Starovoitov <ast@plumgrid.com>
>>> Date: Tue, 22 Apr 2014 20:18:57 -0700
>>>
>>>> exisiting BPF verifier allows uninitialized access to registers,
>>>> 'ret A' is considered to be a valid filter.
>>>> So initialize A and X to zero to prevent leaking kernel memory
>>>> In the future BPF verifier will be rejecting such filters
>>>>
>>>> Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
>>>
>>> Has the code always been like this?
> 
> I think it would be much cleaner to just prevent such filters that
> only contain a 'ret A', or 'ret X' w/o a load into X from attaching.

That choice had to be done two decades ago, not now.

We have to accept such filters, we always have.
