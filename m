From: David Miller <davem@davemloft.net>
Subject: Re: [patch] NET: remove support for Davicom 9102 from the Tulip
 driver
Date: Fri, 04 Apr 2008 15:02:49 -0700 (PDT)
Message-ID: <20080404.150249.132264075.davem@davemloft.net>
References: <Pine.SOC.4.64.0804031209540.2017@math.ut.ee>
	<47F69FBE.3020308@garzik.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mroos@linux.ee, cebbert@redhat.com, netdev@vger.kernel.org,
	grundler@parisc-linux.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41220
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751485AbYDDWCs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Apr 2008 18:02:48 -0400
In-Reply-To: <47F69FBE.3020308@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Garzik <jeff@garzik.org>
Date: Fri, 04 Apr 2008 17:38:06 -0400

> Meelis Roos wrote:
> > CE> We have two reports that agree the tulip driver doesn't work for
> > CE> the Davicom 9102 (PCI id 1282:9102). The dmfe driver does work
> > CE> and also claims the same PCI ID.
> > 
> > NAK, dmfe does not work on some Sparc64 machines but tulip does.
> > 
> > I happent to have a Sun Fire V100 with 2 Davicom NICs (1282:9102 (rev 
> > 31)).
> > tulip driver works for them, dmfe doesn't. Tried with 2.6.25-rc7, first 
> > it
> > gets MAC addresses all zeroed and second, it only results in Tx 
> > timeouts.
> 
> At the very least, it sounds like some SROM parsing problems on dmfe's 
> part -- assuming a standard SROM when sparc64 provides a more 
> complicated one.

With the onboard Sparc64 davicoms, the SROM is essentially empty.

