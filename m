From: Daniele Venzano <webvenza@libero.it>
Subject: Re: [PATCH 1/5] sis900 printk and stack usage audit
Date: Sun, 12 Dec 2004 09:15:09 +0100
Message-ID: <20041212081509.GA3084@picchio.gall.it>
References: <20041208104721.GA31707@picchio.gall.it> <20041208110156.GB31707@picchio.gall.it> <41BB452D.5040507@pobox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Daniele Venzano <webvenza@libero.it>, NetDev <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Jeff Garzik <jgarzik@pobox.com>
Content-Disposition: inline
In-Reply-To: <41BB452D.5040507@pobox.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, Dec 11, 2004 at 02:06:21PM -0500, Jeff Garzik wrote:
> >@@ -390,13 +390,6 @@
> > 	u8 revision;
> > 	char *card_name = card_names[pci_id->driver_data];
> > 
> >-/* when built into the kernel, we only print version if device is found */
> >-#ifndef MODULE
> >-	static int printed_version;
> >-	if (!printed_version++)
> >-		printk(version);
> >-#endif
> >-
> > 	/* setup various bits in PCI command register */
> > 	ret = pci_enable_device(pci_dev);
> > 	if(ret) return ret;
> 
> There is no double-printing.  One is #ifndef MODULE, one is #ifdef MODULE.
> 
> Did you read the comment included in the code you deleted???

My bad, dropped.

-- 
-----------------------------
Daniele Venzano
Web: http://teg.homeunix.org
