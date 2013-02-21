From: Daniel Borkmann <dborkman@redhat.com>
Subject: Re: [GIT PULL nf] IPVS fixes #2
Date: Thu, 21 Feb 2013 12:19:02 +0100
Message-ID: <512602A6.8090609@redhat.com>
References: <1360113878-31051-1-git-send-email-horms@verge.net.au> <20130207181213.GA18181@localhost> <20130213201301.GA7245@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Simon Horman <horms@verge.net.au>, lvs-devel@vger.kernel.org,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	Wensong Zhang <wensong@linux-vs.org>,
	Julian Anastasov <ja@ssi.bg>
To: Pablo Neira Ayuso <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53056 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753831Ab3BULUQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Feb 2013 06:20:16 -0500
In-Reply-To: <20130213201301.GA7245@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/13/2013 09:13 PM, Pablo Neira Ayuso wrote:
> On Thu, Feb 07, 2013 at 07:12:13PM +0100, Pablo Neira Ayuso wrote:
>> On Wed, Feb 06, 2013 at 10:24:37AM +0900, Simon Horman wrote:
>>> Hi Pablo,
>>>
>>> Another fix. This one seems suitable for stable all the way back to
>>> 2.6.34. I suspect this change may not apply cleanly all the way back there.
>>> Please let me know if I should prepare some backports.
>
> While reviewing patches that I'll pass to -stable, I noticed that:
>
> 4b47bc9 ipvs: sctp: fix checksumming on snat and dnat handlers
>
> depends on:
>
> commit d4383f04d145cce8b855c463f40020639ef83ea0
> Author: Jesper Dangaard Brouer <brouer@redhat.com>
> Date:   Wed Sep 26 14:07:17 2012 +0200
>
>      ipvs: API change to avoid rescan of IPv6 exthdr
>
> which is too big to add as dependency (it does not fulfill -stable
> rule of not bigger patches than 100 lines).
>
> If you want to me pass this sctp fix to -stable, you or Daniel will
> have to send me a backport.

I'm currently working on it. Will send you a patch by today.

Thanks.
