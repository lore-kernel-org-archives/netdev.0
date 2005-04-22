From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: Patch for USR r8169 clone
Date: Fri, 22 Apr 2005 20:31:13 +0200
Message-ID: <20050422183113.GA12371@electric-eye.fr.zoreil.com>
References: <42693753.7010907@xs4all.nl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Ruud Linders <rkmp@xs4all.nl>
Content-Disposition: inline
In-Reply-To: <42693753.7010907@xs4all.nl>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Ruud Linders <rkmp@xs4all.nl> :
[pci id for the r8169 based network adapter made by USR]
> Please consider including in next update to r8169.c.

Thanks for your work but the same patch has been sent to Andrew Morton,
Jeff Garzik and our favorite netdev@oss.sgi.com mailing list the 11 of
april 2005.

> --- r8169.c.ORIG	2004-12-25 11:36:12.000000000 +0100
> +++ r8169.c	2005-04-22 19:18:12.000000000 +0200
> @@ -151,6 +151,7 @@
>  static struct pci_device_id rtl8169_pci_tbl[] = {
>  	{0x10ec, 0x8169, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0},
>  	{0x1186, 0x4300, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0},
> +	{0x16EC, 0x0116, PCI_ANY_ID, PCI_ANY_ID, 0, 0, 0},

(nit: s/EC/ec/)

--
Ueimor
