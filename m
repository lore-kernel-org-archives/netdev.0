From: jamal <hadi@cyberus.ca>
Subject: Re: ip xfrm bug
Date: Sun, 23 Dec 2007 08:06:45 -0500
Message-ID: <1198415205.4423.86.camel@localhost>
References: <Pine.LNX.4.64.0711291131080.21906@newtla.xelerance.com>
	 <20071214091659.GA16129@gondor.apana.org.au>
	 <20071214112118.118862c3@deepthought>
	 <20071216074359.GA2800@gondor.apana.org.au>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	Paul Wouters <paul@xelerance.com>, dev@openswan.org,
	netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.181]:52940 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752129AbXLWNGx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Dec 2007 08:06:53 -0500
Received: by wa-out-1112.google.com with SMTP id v27so1942748wah.23
        for <netdev@vger.kernel.org>; Sun, 23 Dec 2007 05:06:53 -0800 (PST)
In-Reply-To: <20071216074359.GA2800@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2007-16-12 at 15:43 +0800, Herbert Xu wrote:

> Jamal's going to hate me but setkey(8) already uses this so we're
> stuck with it anyway.
> 
> The test is
> 
> 	up->index % 8 >= 3
> 
> This is true iff it's a socket policy.

I would have loved it if user space had a say ;-> 
In the case of tc actions for example; the (table) index abides to the
following rules:

 if user space specified one in rule insertion then {
     if available, use the allowed entry {
     } else if inuse {
         if replace flag is set then {
            replace
        } else {
         return error
     }
  } else {
   grab the next available index
  }

makes management from user space much simpler.

cheers,
jamal

