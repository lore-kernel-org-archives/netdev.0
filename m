From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 3/4] xfrm: remove policy lock when accessing
 policy->walk.dead
Date: Wed, 31 Mar 2010 10:12:48 -0400
Message-ID: <1270044768.26743.58.camel@bigi>
References: <1270030626-16687-1-git-send-email-timo.teras@iki.fi>
	 <1270030626-16687-5-git-send-email-timo.teras@iki.fi>
	 <20100331110345.GC12845@gondor.apana.org.au>
	 <1270040773.26743.12.camel@bigi>
	 <20100331131131.GA13793@gondor.apana.org.au>
	 <20100331132622.GA13908@gondor.apana.org.au>
	 <1270042356.26743.30.camel@bigi> <1270042795.26743.31.camel@bigi>
	 <20100331135505.GC14082@gondor.apana.org.au>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Timo Teras <timo.teras@iki.fi>, netdev@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f220.google.com ([209.85.219.220]:58491 "EHLO
	mail-ew0-f220.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754937Ab0CaOMz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 31 Mar 2010 10:12:55 -0400
Received: by ewy20 with SMTP id 20so43783ewy.1
        for <netdev@vger.kernel.org>; Wed, 31 Mar 2010 07:12:54 -0700 (PDT)
In-Reply-To: <20100331135505.GC14082@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2010-03-31 at 21:55 +0800, Herbert Xu wrote:

> Eliding the notification if SELinux says so is fine, but eliding
> it because the table is empty is wrong.
> 
> The flush did not fail just because the table was empty to begin
> with.

Like i said i didnt touch the behavior except for the selinux case
(which sounds very reasonable). I believe there maybe historical legacy
reasons for that semantic in pfkey. 
Can you point to something in the kernel (or anywhere else) that behaves
like this on table flushing? Actually if there was an app that depended
on netlink flush being exposed on empty table - then i think theres
reason for a revert.
Other than that i will say again: i respectfully disagree.

cheers,
jamal

