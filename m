From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net loopback: Set loopback_dev to NULL when
 freed
Date: Tue, 17 Sep 2013 19:05:27 -0400 (EDT)
Message-ID: <20130917.190527.1991946387265699150.davem@davemloft.net>
References: <20130916.213435.1508866100258405440.davem@davemloft.net>
	<1379382102.4751.2.camel@edumazet-glaptop>
	<87k3igcizo.fsf@xmission.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: eric.dumazet@gmail.com, edumazet@google.com, jiri@resnulli.us,
	alexander.h.duyck@intel.com, amwang@redhat.com,
	netdev@vger.kernel.org, fruggeri@aristanetworks.com
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:43365 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753379Ab3IQXFa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Sep 2013 19:05:30 -0400
In-Reply-To: <87k3igcizo.fsf@xmission.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Mon, 16 Sep 2013 18:52:27 -0700

> Eric Dumazet <eric.dumazet@gmail.com> writes:
> 
>> On Mon, 2013-09-16 at 21:34 -0400, David Miller wrote:
>>> From: Eric Dumazet <eric.dumazet@gmail.com>
>>> Date: Mon, 16 Sep 2013 17:50:51 -0700
>>> 
>>> > On Mon, 2013-09-16 at 16:52 -0700, Eric W. Biederman wrote:
>>> >> It has recently turned up that we have a number of long standing bugs
>>> >> in the network stack cleanup code with use of the loopback device
>>> >> after it has been freed that have not turned up because in most cases
>>> >> the storage allocated to the loopback device is not reused, when those
>>> >> accesses happen.
>>> >> 
>>> >> Set looback_dev to NULL to trigger oopses instead of silent data corrupt
>>> >> when we hit this class of bug.
>>> >> 
>>> >> Signed-off-by: "Eric W. Biederman" <ebiederm@xmission.com>
>>> >> ---
>>> > 
>>> > Acked-by: Eric Dumazet <edumazet@google.com>
>>> 
>>> I'd like to apply this to 'net', any objections?
>>
>> No objections from me.
> 
> No objects from me I just hadn't seen it as a bug fix, but I guess it
> sort of is.

Ok, done.
