From: Alan Cox <alan@lxorguk.ukuu.org.uk>
Subject: Re: [patch 04/13] 8390: Split 8390 support into a pausing and a non
 pausing driver core
Date: Tue, 10 Jun 2008 00:52:47 +0100
Message-ID: <20080610005247.6230fec1@core>
References: <200806092333.m59NXnTe014676@imap1.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: jeff@garzik.org, netdev@vger.kernel.org, akpm@linux-foundation.org,
	alan@redhat.com, randy.dunlap@oracle.com
To: akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from earthlight.etchedpixels.co.uk ([81.2.110.250]:43037 "EHLO
	lxorguk.ukuu.org.uk" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753329AbYFJAKf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Jun 2008 20:10:35 -0400
In-Reply-To: <200806092333.m59NXnTe014676@imap1.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 09 Jun 2008 16:33:49 -0700
akpm@linux-foundation.org wrote:

> From: Alan Cox <alan@lxorguk.ukuu.org.uk>
> 
> Only a few ISA controllers need the pausing version of the 8390 core
> while PCMCIA, later ISA and PCI do not. More importantly the ISA delays
> can break non ISA boxes so we must use a different build of 8390.c for
> the two sets of controllers.
> 
> No changes since last time as all the points of concerns raised proved to
> be invalid
> 
> [randy.dunlap@oracle.com: ne2 (MCA) needs both 8390.o and 8390p.o functions]

ne2 does not need both, it hasn't needed both and its completely invalid
to have both in one driver. Please drop Randy's change out and fix the
actual typo instead.

Alan
