From: "Sivakumar Subramani" <Sivakumar.Subramani@neterion.com>
Subject: RE: drivers/net/tokenring/3c359.c
Date: Thu, 16 Aug 2007 02:43:11 -0400
Message-ID: <78C9135A3D2ECE4B8162EBDCE82CAD77020EEEC6@nekter>
References: <1187000010.29518.27.camel@bluegenie> <46C14297.1050800@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <mikep@linuxtr.net>, <netdev@vger.kernel.org>,
	<linux-tr@linuxtr.net>,
	"Linux Kernel" <linux-kernel@vger.kernel.org>,
	"kernel-janitors" <kernel-janitors@lists.osdl.org>
To: "Jeff Garzik" <jeff@garzik.org>, <surya.prabhakar@wipro.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx.neterion.com ([72.1.205.142]:15542 "EHLO owa.neterion.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751139AbXHPGmX convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 16 Aug 2007 02:42:23 -0400
Content-class: urn:content-classes:message
In-Reply-To: <46C14297.1050800@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

What exactly the difference between kzalloc and kcalloc? From the
definition, I could see that kcalloc should be used for array
allocation. But I could see kzalloc is used for allocation arrays as in
the below patch.

Any coding standard (or) developers can use kzalloc and kcalloc as per
their coding practice??

Thanks,
~Siva
-----Original Message-----
From: netdev-owner@vger.kernel.org [mailto:netdev-owner@vger.kernel.org]
On Behalf Of Jeff Garzik
Sent: Tuesday, August 14, 2007 11:20 AM
To: surya.prabhakar@wipro.com
Cc: mikep@linuxtr.net; netdev@vger.kernel.org; linux-tr@linuxtr.net;
Linux Kernel; kernel-janitors
Subject: Re: drivers/net/tokenring/3c359.c

Surya Prabhakar N wrote:
> Hi,
>    Replacing kmalloc with kzalloc and cleaning up memset in 
> drivers/net/tokenring/3c359.c
> 
> 
> Signed-off-by: Surya Prabhakar <surya.prabhakar@wipro.com>

applied


-
To unsubscribe from this list: send the line "unsubscribe netdev" in the
body of a message to majordomo@vger.kernel.org More majordomo info at
http://vger.kernel.org/majordomo-info.html
