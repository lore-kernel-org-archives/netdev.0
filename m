From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [PATCH net] net: filter: initialize A and X registers
Date: Wed, 23 Apr 2014 19:20:41 +0200
Message-ID: <5357F669.8090200@redhat.com>
References: <20140422.235745.1219194947074686642.davem@davemloft.net> <CAMEtUux=mOyZkfxMWi3eA01TvmJrfJpeBpGcHvheptcckA=dzQ@mail.gmail.com> <5357659E.1070807@redhat.com> <20140423.125235.1748012189632512309.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: ast@plumgrid.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:21888 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751335AbaDWRUs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Apr 2014 13:20:48 -0400
In-Reply-To: <20140423.125235.1748012189632512309.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/23/2014 06:52 PM, David Miller wrote:
...
>> I think it would be much cleaner to just prevent such filters that
>> only contain a 'ret A', or 'ret X' w/o a load into X from attaching.
>
> That choice had to be done two decades ago, not now.
>
> We have to accept such filters, we always have.

Yep, very true. :/
