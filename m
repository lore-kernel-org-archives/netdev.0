From: David Gibson <hermes@gibson.dropbear.id.au>
Subject: Re: [Orinoco-devel] Re: [8/14] Orinoco driver updates - PCMCIA initialization cleanups
Date: Fri, 25 Feb 2005 16:03:10 +1100
Message-ID: <20050225050310.GF10725@localhost.localdomain>
References: <20050224035445.GB32001@localhost.localdomain> <20050224035524.GC32001@localhost.localdomain> <20050224035650.GD32001@localhost.localdomain> <20050224035718.GE32001@localhost.localdomain> <20050224035804.GF32001@localhost.localdomain> <20050224035957.GH32001@localhost.localdomain> <20050224040024.GI32001@localhost.localdomain> <20050224040052.GJ32001@localhost.localdomain> <20050224065527.GA8931@isilmar.linta.de> <421D8241.9020608@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Dominik Brodowski <linux@dominikbrodowski.net>,
	Pavel Roskin <proski@gnu.org>,
	Orinoco Development List <orinoco-devel@lists.sourceforge.net>,
	netdev@oss.sgi.com, linux-kernel@vger.kernel.org
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <421D8241.9020608@pobox.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Feb 24, 2005 at 02:29:05AM -0500, Jeff Garzik wrote:
> Dominik Brodowski wrote:
> >>@@ -184,6 +186,7 @@
> >>	dev_list = link;
> >>
> >>	client_reg.dev_info = &dev_info;
> >>+	client_reg.Attributes = INFO_IO_CLIENT | INFO_CARD_SHARE;
> >
> >
> >That's not needed any longer for 2.6.
> 
> So who wants to send the incremental update patch?  :)

Guess I will.  See below.

Any particular reason the field and associated constants haven't been
exunged from the tree, since they're no longer used?

The client_reg.Attributes field is no longer used.  Don't bother
setting it.

Signed-off-by: David Gibson <hermes@gibson.dropbear.id.au>

Index: working-2.6/drivers/net/wireless/orinoco_cs.c
===================================================================
--- working-2.6.orig/drivers/net/wireless/orinoco_cs.c	2005-02-25 15:47:53.098405968 +1100
+++ working-2.6/drivers/net/wireless/orinoco_cs.c	2005-02-25 15:52:56.000000000 +1100
@@ -186,7 +186,6 @@
 	dev_list = link;
 
 	client_reg.dev_info = &dev_info;
-	client_reg.Attributes = INFO_IO_CLIENT | INFO_CARD_SHARE;
 	client_reg.EventMask =
 		CS_EVENT_CARD_INSERTION | CS_EVENT_CARD_REMOVAL |
 		CS_EVENT_RESET_PHYSICAL | CS_EVENT_CARD_RESET |


-- 
David Gibson			| I'll have my music baroque, and my code
david AT gibson.dropbear.id.au	| minimalist.  NOT _the_ _other_ _way_
				| _around_!
http://www.ozlabs.org/people/dgibson
