From: Oliver Hartkopp <oliver@hartkopp.net>
Subject: Re: [Bugme-new] [Bug 13627] New: Tunnel device ignores TCP/UDP traffic
Date: Sat, 27 Jun 2009 18:37:21 +0200
Message-ID: <4A464AC1.3070906@hartkopp.net>
References: <bug-13627-10286@http.bugzilla.kernel.org/>	<20090626124444.c24d9b38.akpm@linux-foundation.org>	<20090627020403.GB19639@gondor.apana.org.au> <20090626.192247.17381002.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, akpm@linux-foundation.org,
	netdev@vger.kernel.org, bugzilla-daemon@bugzilla.kernel.org,
	bugme-daemon@bugzilla.kernel.org, pm@debian.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.161]:48702 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753065AbZF0Qhc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Jun 2009 12:37:32 -0400
In-Reply-To: <20090626.192247.17381002.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller wrote:
> From: Herbert Xu <herbert@gondor.apana.org.au>
> Date: Sat, 27 Jun 2009 10:04:03 +0800
> 
>> On Fri, Jun 26, 2009 at 12:44:44PM -0700, Andrew Morton wrote:
>>> It's a post-2.6.30 regression which Paul has bisected down to
>>>
>>>   commit d55d87fdff8252d0e2f7c28c2d443aee17e9d70f
>>>   Author:     Herbert Xu <herbert@gondor.apana.org.au>
>>>   AuthorDate: Mon Jun 22 02:25:25 2009 +0000
>>>   Commit:     David S. Miller <davem@davemloft.net>
>>>   CommitDate: Tue Jun 23 16:36:25 2009 -0700
>>>
>>>       net: Move rx skb_orphan call to where needed
>>>
>>> (thanks for doing the bisection!)
>> Doh, I'd forgotten about transparent proxying.
>>
>> inet: Call skb_orphan before tproxy activates
>>
>> As transparent proxying looks up the socket early and assigns
>> it to the skb for later processing, we must drop any existing
>> socket ownership prior to that in order to distinguish between
>> the case where tproxy is active and where it is not.
>>
>> Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>
> 
> Applied, thanks Herbert.

Hi Dave,

just a reminder, if you already queued up the original patch for
2.6.30-stable, that this patch has to follow then also.

Thanks,
Oliver
