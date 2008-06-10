From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [patch 04/13] 8390: Split 8390 support into a pausing and a non
 pausing driver core
Date: Mon, 9 Jun 2008 17:15:32 -0700
Message-ID: <20080609171532.32eb5a95.akpm@linux-foundation.org>
References: <200806092333.m59NXnTe014676@imap1.linux-foundation.org>
	<20080610005247.6230fec1@core>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org, alan@redhat.com,
	randy.dunlap@oracle.com
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:37664 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752119AbYFJAQ2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jun 2008 20:16:28 -0400
In-Reply-To: <20080610005247.6230fec1@core>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 10 Jun 2008 00:52:47 +0100
Alan Cox <alan@lxorguk.ukuu.org.uk> wrote:

> On Mon, 09 Jun 2008 16:33:49 -0700
> akpm@linux-foundation.org wrote:
> 
> > From: Alan Cox <alan@lxorguk.ukuu.org.uk>
> > 
> > Only a few ISA controllers need the pausing version of the 8390 core
> > while PCMCIA, later ISA and PCI do not. More importantly the ISA delays
> > can break non ISA boxes so we must use a different build of 8390.c for
> > the two sets of controllers.
> > 
> > No changes since last time as all the points of concerns raised proved to
> > be invalid
> > 
> > [randy.dunlap@oracle.com: ne2 (MCA) needs both 8390.o and 8390p.o functions]
> 
> ne2 does not need both, it hasn't needed both and its completely invalid
> to have both in one driver. Please drop Randy's change out and fix the
> actual typo instead.
> 

This patch sat in my tree for weeks causing build errors, then Randy
sent a fix and after that it didn't cause any build errors any more.

I do not know what typo you are referring to.

