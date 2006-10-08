From: Dmitry Torokhov <dtor@insightbb.com>
Subject: [patch 3/3] atmel: whitespace cleanup
Date: Sun, 08 Oct 2006 00:14:30 -0400
Message-ID: <20061008041552.229331802.dtor@insightbb.com>
References: <20061008041427.216886195.dtor@insightbb.com>
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from gateway.insightbb.com ([74.128.0.19]:36003 "EHLO
	asav08.insightbb.com") by vger.kernel.org with ESMTP
	id S1750784AbWJHERi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 8 Oct 2006 00:17:38 -0400
To: linville@tuxdriver.com
Content-Disposition: inline; filename=atmel-whitespace.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

NET: atmel: whitespace cleanup

Signed-off-by: Dmitry Torokhov <dtor@mail.ru>
---

 drivers/net/wireless/atmel.c     |    6 +--
 drivers/net/wireless/atmel_cs.c  |   74 +++++++++++++++++++--------------------
 drivers/net/wireless/atmel_pci.c |   10 ++---
 3 files changed, 45 insertions(+), 45 deletions(-)

Index: work/drivers/net/wireless/atmel.c
===================================================================
--- work.orig/drivers/net/wireless/atmel.c
+++ work/drivers/net/wireless/atmel.c
@@ -595,7 +595,7 @@ static void atmel_join_bss(struct atmel_
 static void atmel_smooth_qual(struct atmel_private *priv);
 static void atmel_writeAR(struct net_device *dev, u16 data);
 static int probe_atmel_card(struct net_device *dev);
-static int reset_atmel_card(struct net_device *dev );
+static int reset_atmel_card(struct net_device *dev);
 static void atmel_enter_state(struct atmel_private *priv, int new_state);
 int atmel_open (struct net_device *dev);
 
@@ -1738,7 +1738,7 @@ static int atmel_set_encode(struct net_d
 				/* Disable the key */
 				priv->wep_key_len[index] = 0;
 		/* Check if the key is not marked as invalid */
-		if(!(dwrq->flags & IW_ENCODE_NOKEY)) {
+		if (!(dwrq->flags & IW_ENCODE_NOKEY)) {
 			/* Cleanup */
 			memset(priv->wep_keys[index], 0, 13);
 			/* Copy the key in the driver */
@@ -1909,7 +1909,7 @@ static int atmel_get_encodeext(struct ne
 
 	encoding->flags = idx + 1;
 	memset(ext, 0, sizeof(*ext));
-	
+
 	if (!priv->wep_is_on) {
 		ext->alg = IW_ENCODE_ALG_NONE;
 		ext->key_len = 0;
Index: work/drivers/net/wireless/atmel_cs.c
===================================================================
--- work.orig/drivers/net/wireless/atmel_cs.c
+++ work/drivers/net/wireless/atmel_cs.c
@@ -5,12 +5,12 @@
         Copyright 2000-2001 ATMEL Corporation.
         Copyright 2003 Simon Kelley.
 
-    This code was developed from version 2.1.1 of the Atmel drivers, 
-    released by Atmel corp. under the GPL in December 2002. It also 
-    includes code from the Linux aironet drivers (C) Benjamin Reed, 
-    and the Linux PCMCIA package, (C) David Hinds. 
+    This code was developed from version 2.1.1 of the Atmel drivers,
+    released by Atmel corp. under the GPL in December 2002. It also
+    includes code from the Linux aironet drivers (C) Benjamin Reed,
+    and the Linux PCMCIA package, (C) David Hinds.
 
-    For all queries about this code, please contact the current author, 
+    For all queries about this code, please contact the current author,
     Simon Kelley <simon@thekelleys.org.uk> and not Atmel Corporation.
 
     This program is free software; you can redistribute it and/or modify
@@ -87,7 +87,7 @@ MODULE_SUPPORTED_DEVICE("Atmel at76c50x 
    event is received.  The config() and release() entry points are
    used to configure or release a socket, in response to card
    insertion and ejection events.  They are invoked from the atmel_cs
-   event handler. 
+   event handler.
 */
 
 static int atmel_config(struct pcmcia_device *link);
@@ -133,22 +133,22 @@ static void atmel_detach(struct pcmcia_d
    device IO routines can use a flag like this to throttle IO to a
    card that is not ready to accept it.
 */
-   
+
 typedef struct local_info_t {
 	dev_node_t	node;
 	struct net_device *eth_dev;
 } local_info_t;
 
 /*======================================================================
-  
+
   atmel_attach() creates an "instance" of the driver, allocating
   local data structures for one device.  The device is registered
   with Card Services.
-  
+
   The dev_link structure is initialized, but we don't actually
   configure the card at this point -- we wait until we receive a
   card insertion event.
-  
+
   ======================================================================*/
 
 static int atmel_probe(struct pcmcia_device *p_dev)
@@ -184,12 +184,12 @@ static int atmel_probe(struct pcmcia_dev
 } /* atmel_attach */
 
 /*======================================================================
-  
+
   This deletes a driver "instance".  The device is de-registered
   with Card Services.  If it has been released, all local data
   structures are freed.  Otherwise, the structures will be freed
   when the device is released.
-  
+
   ======================================================================*/
 
 static void atmel_detach(struct pcmcia_device *link)
@@ -202,11 +202,11 @@ static void atmel_detach(struct pcmcia_d
 }
 
 /*======================================================================
-  
+
   atmel_config() is scheduled to run after a CARD_INSERTION event
   is received, to configure the PCMCIA socket, and to make the
   device available to the system.
-  
+
   ======================================================================*/
 
 #define CS_CHECK(fn, ret) \
@@ -237,12 +237,12 @@ static int atmel_config(struct pcmcia_de
 	did = handle_to_dev(link).driver_data;
 
 	DEBUG(0, "atmel_config(0x%p)\n", link);
-	
+
 	tuple.Attributes = 0;
 	tuple.TupleData = buf;
 	tuple.TupleDataMax = sizeof(buf);
 	tuple.TupleOffset = 0;
-	
+
 	/*
 	  This reads the card's CONFIG tuple to find its configuration
 	  registers.
@@ -258,7 +258,7 @@ static int atmel_config(struct pcmcia_de
 	  In this loop, we scan the CIS for configuration table entries,
 	  each of which describes a valid card configuration, including
 	  voltage, IO window, memory window, and interrupt settings.
-	  
+
 	  We make no assumptions about the card to be configured: we use
 	  just the information available in the CIS.  In an ideal world,
 	  this would work for any PCMCIA card, but it requires a complete
@@ -274,17 +274,17 @@ static int atmel_config(struct pcmcia_de
 		if (pcmcia_get_tuple_data(link, &tuple) != 0 ||
 				pcmcia_parse_tuple(link, &tuple, &parse) != 0)
 			goto next_entry;
-		
+
 		if (cfg->flags & CISTPL_CFTABLE_DEFAULT) dflt = *cfg;
 		if (cfg->index == 0) goto next_entry;
 		link->conf.ConfigIndex = cfg->index;
-		
+
 		/* Does this card need audio output? */
 		if (cfg->flags & CISTPL_CFTABLE_AUDIO) {
 			link->conf.Attributes |= CONF_ENABLE_SPKR;
 			link->conf.Status = CCSR_AUDIO_ENA;
 		}
-		
+
 		/* Use power settings for Vcc and Vpp if present */
 		/*  Note that the CIS values need to be rescaled */
 		if (cfg->vpp1.present & (1<<CISTPL_POWER_VNOM))
@@ -293,11 +293,11 @@ static int atmel_config(struct pcmcia_de
 		else if (dflt.vpp1.present & (1<<CISTPL_POWER_VNOM))
 			link->conf.Vpp =
 				dflt.vpp1.param[CISTPL_POWER_VNOM]/10000;
-		
+
 		/* Do we need to allocate an interrupt? */
 		if (cfg->irq.IRQInfo1 || dflt.irq.IRQInfo1)
 			link->conf.Attributes |= CONF_ENABLE_IRQ;
-		
+
 		/* IO window settings */
 		link->io.NumPorts1 = link->io.NumPorts2 = 0;
 		if ((cfg->io.nwin > 0) || (dflt.io.nwin > 0)) {
@@ -315,18 +315,18 @@ static int atmel_config(struct pcmcia_de
 				link->io.NumPorts2 = io->win[1].len;
 			}
 		}
-		
+
 		/* This reserves IO space but doesn't actually enable it */
 		if (pcmcia_request_io(link, &link->io) != 0)
 			goto next_entry;
 
 		/* If we got this far, we're cool! */
 		break;
-		
+
 	next_entry:
 		CS_CHECK(GetNextTuple, pcmcia_get_next_tuple(link, &tuple));
 	}
-	
+
 	/*
 	  Allocate an interrupt line.  Note that this does not assign a
 	  handler to the interrupt, unless the 'Handler' member of the
@@ -334,31 +334,31 @@ static int atmel_config(struct pcmcia_de
 	*/
 	if (link->conf.Attributes & CONF_ENABLE_IRQ)
 		CS_CHECK(RequestIRQ, pcmcia_request_irq(link, &link->irq));
-	
+
 	/*
 	  This actually configures the PCMCIA socket -- setting up
 	  the I/O windows and the interrupt mapping, and putting the
 	  card and host interface into "Memory and IO" mode.
 	*/
 	CS_CHECK(RequestConfiguration, pcmcia_request_configuration(link, &link->conf));
-	
+
 	if (link->irq.AssignedIRQ == 0) {
-		printk(KERN_ALERT 
+		printk(KERN_ALERT
 		       "atmel: cannot assign IRQ: check that CONFIG_ISA is set in kernel config.");
 		goto cs_failed;
 	}
-       
-	((local_info_t*)link->priv)->eth_dev = 
+
+	((local_info_t*)link->priv)->eth_dev =
 		init_atmel_card(link->irq.AssignedIRQ,
 				link->io.BasePort1,
 				did ? did->driver_info : ATMEL_FW_TYPE_NONE,
 				&handle_to_dev(link),
-				card_present, 
+				card_present,
 				link);
-	if (!((local_info_t*)link->priv)->eth_dev) 
+	if (!((local_info_t*)link->priv)->eth_dev)
 			goto cs_failed;
-	
-	
+
+
 	/*
 	  At this point, the dev_node_t structure(s) need to be
 	  initialized and arranged in a linked list at link->dev_node.
@@ -376,11 +376,11 @@ static int atmel_config(struct pcmcia_de
 }
 
 /*======================================================================
-  
+
   After a card is removed, atmel_release() will unregister the
   device, and release the PCMCIA configuration.  If the device is
   still open, this will be postponed until it is closed.
-  
+
   ======================================================================*/
 
 static void atmel_release(struct pcmcia_device *link)
@@ -517,7 +517,7 @@ static void atmel_cs_cleanup(void)
     HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT,
     STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING
     IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
-    POSSIBILITY OF SUCH DAMAGE.    
+    POSSIBILITY OF SUCH DAMAGE.
 */
 
 module_init(atmel_cs_init);
Index: work/drivers/net/wireless/atmel_pci.c
===================================================================
--- work.orig/drivers/net/wireless/atmel_pci.c
+++ work/drivers/net/wireless/atmel_pci.c
@@ -53,18 +53,18 @@ static int __devinit atmel_pci_probe(str
 				     const struct pci_device_id *pent)
 {
 	struct net_device *dev;
-		
+
 	if (pci_enable_device(pdev))
 		return -ENODEV;
-	
+
 	pci_set_master(pdev);
-	
-	dev = init_atmel_card(pdev->irq, pdev->resource[1].start, 
+
+	dev = init_atmel_card(pdev->irq, pdev->resource[1].start,
 			      ATMEL_FW_TYPE_506,
 			      &pdev->dev, NULL, NULL);
 	if (!dev)
 		return -ENODEV;
-	
+
 	pci_set_drvdata(pdev, dev);
 	return 0;
 }
