From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: Error acx-20060215 wireless module
Date: Fri, 14 Jul 2006 13:10:41 -0400
Message-ID: <20060714171036.GC1738@tuxdriver.com>
References: <44B7C18E.2070306@fastwebnet.it>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:6418 "EHLO ra.tuxdriver.com")
	by vger.kernel.org with ESMTP id S1161270AbWGNRKx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Jul 2006 13:10:53 -0400
To: VinX <vincenx@fastwebnet.it>
Content-Disposition: inline
In-Reply-To: <44B7C18E.2070306@fastwebnet.it>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Jul 14, 2006 at 06:08:46PM +0200, VinX wrote:
> Hi,
> on my gentoo with kernel 2.6.18-rc1 I had this error:
> --
>   CC [M]  /var/tmp/portage/acx-0.3.35/work/pci.o
> /var/tmp/portage/acx-0.3.35/work/pci.c: In function `acxpci_e_probe':
> /var/tmp/portage/acx-0.3.35/work/pci.c:1652: error: `UTS_RELEASE' 
> undeclared (first use in this function)
> /var/tmp/portage/acx-0.3.35/work/pci.c:1652: error: (Each undeclared 
> identifier is reported only once
> /var/tmp/portage/acx-0.3.35/work/pci.c:1652: error: for each function it 
> appears in.)
> make[1]: *** [/var/tmp/portage/acx-0.3.35/work/pci.o] Error 1
> --
> I think that it's missing <linux/utsrelease.h> on this file!

The tiacx driver in wireless-2.6 has a patch for this issue.

John
-- 
John W. Linville
linville@tuxdriver.com
