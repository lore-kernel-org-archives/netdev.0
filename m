From: Jarek Poplawski <jarkao2@gmail.com>
Subject: Re: [AX25] kernel panic
Date: Thu, 20 Mar 2008 07:30:21 +0000
Message-ID: <20080320073021.GA4037@ff.dom.local>
References: <47DF9D21.20807@free.fr> <20080318212531.GA2031@electric-eye.fr.zoreil.com> <47E0C261.3000106@free.fr> <47E17E2E.9050105@free.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Bernard Pidoux F6BVP <f6bvp@free.fr>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Jarek Poplawski <jarkao2@o2.pl>
To: Bernard Pidoux <bpidoux@free.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nf-out-0910.google.com ([64.233.182.191]:14280 "EHLO
	nf-out-0910.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752625AbYCTH2f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Mar 2008 03:28:35 -0400
Received: by nf-out-0910.google.com with SMTP id g13so393965nfb.21
        for <netdev@vger.kernel.org>; Thu, 20 Mar 2008 00:28:34 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <47E17E2E.9050105@free.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Mar 19, 2008 at 09:57:18PM +0100, Bernard Pidoux wrote:
...
> I also tried to revert Jarek's mkiss ax_bump() patch, but this did not  
> prevent
> kernel lockup, although this time swapper is involved and not ax25ipd.
...
> BUG: unable to handle kernel paging request at virtual address 6b6b6c2b
> printing eip: c013fc67 *pde = 00000000
> Oops: 0002 [#1] SMP

Well, the rest looks very similarly and not trivial... Probably a
socket is destructed too soon (or something...). Could you try to
reproduce this with some debugging turned off, e.g.:
CONFIG_DEBUG_LOCK_ALLOC, CONFIG_DEBUG_PAGEALLOC, (CONFIG_SLUB_DEBUG?).

Regards,
Jarek P.
