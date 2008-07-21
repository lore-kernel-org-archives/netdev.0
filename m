From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [build failure] hp-plus.c: (.text+0xd7c1a): undefined reference
 to `ei_close'
Date: Mon, 21 Jul 2008 21:42:58 +0100
Message-ID: <20080721214258.787a67ca@lxorguk.ukuu.org.uk>
References: <20080721.233512.128618365.anemo@mba.ocn.ne.jp>
	<20080721191519.GA15843@elte.hu>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Atsushi Nemoto <anemo@mba.ocn.ne.jp>, jgarzik@redhat.com,
	akpm@linux-foundation.org, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: Ingo Molnar <mingo@elte.hu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from earthlight.etchedpixels.co.uk ([81.2.110.250]:60625 "EHLO
	lxorguk.ukuu.org.uk" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1755138AbYGUVBd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Jul 2008 17:01:33 -0400
In-Reply-To: <20080721191519.GA15843@elte.hu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 21 Jul 2008 21:15:19 +0200
Ingo Molnar <mingo@elte.hu> wrote:

> 
> * Atsushi Nemoto <anemo@mba.ocn.ne.jp> wrote:
> 
> > Since commit 055e5110ae0c0c1176a75b78d789294f2ff2f7af ("8390: Split
> > 8390 support into a pausing and a non pausing driver core"), ne.c
> > cause this build failure:
> > 
> > drivers/built-in.o: In function `ne_probe1':
> > ne.c:(.init.text+0x2464): undefined reference to `NS8390_init'
> > drivers/built-in.o: In function `ne_block_output':
> > ne.c:(.text.ne_block_output+0x1b0): undefined reference to `NS8390_init'
> 
> i just triggered a similar build failure, but in a different 
> ne2000-derived file:

I'll take a look. Various odd things happened with the Makefile for this
patch and the follow up fixes. If the followup didn't get applied then
that might explain the breakage.

