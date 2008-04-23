From: Joakim Koskela <joakim.koskela@hiit.fi>
Subject: Re: [RFC PATCH resend]: Fix output for BEET ipsec
Date: Wed, 23 Apr 2008 10:13:38 +0300
Message-ID: <200804231013.38390.joakim.koskela@hiit.fi>
References: <200803261115.26157.joakim.koskela@hiit.fi> <200804221512.40780.joakim.koskela@hiit.fi> <20080422131358.GA20418@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from creon.otaverkko.fi ([212.68.0.5]:45569 "EHLO creon.otaverkko.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750828AbYDWHLA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Apr 2008 03:11:00 -0400
In-Reply-To: <20080422131358.GA20418@gondor.apana.org.au>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 22 April 2008 16:13, Herbert Xu wrote:
> On Tue, Apr 22, 2008 at 03:12:40PM +0300, Joakim Koskela wrote:
> > Thanks, but I'm still having problems with 6-6 and the interfamilies.
> >
> > Here's what I'm using right now to get net-2.6 beet working (testing with
> > older versions and another implementation). It's basically the same as I
> > sent before, slightly updated (to use the protocol-independent
> > accessors).
>
> You know it would really help if you told us what problems you're
> having rather than just resending the patch over and over again :)

Sorry, I know really should. I'll try to get back on this asap with some more 
details. But in a nutshell - I get crashes on 4-6 (inner-outer), and although 
6-4 gets packets on the wire, they're somehow wrong. Hm, don't actually think 
there's anything wrong with 6-6 though, I'll have to recheck that.. 

Cheers, 
j
