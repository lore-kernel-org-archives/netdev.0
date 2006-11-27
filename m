From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: 2.6.19-rc6-mm1: drivers/net/chelsio/: unused code
Date: Mon, 27 Nov 2006 10:24:55 -0800
Message-ID: <20061127102455.362fe88f@dxpl.pdx.osdl.net>
References: <20061123021703.8550e37e.akpm@osdl.org>
	<20061124001731.GO3557@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@osdl.org>, linux-kernel@vger.kernel.org,
	Jeff Garzik <jeff@garzik.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.25]:48775 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S932313AbWK0S2Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Nov 2006 13:28:25 -0500
To: Adrian Bunk <bunk@stusta.de>
In-Reply-To: <20061124001731.GO3557@stusta.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 24 Nov 2006 01:17:31 +0100
Adrian Bunk <bunk@stusta.de> wrote:

> On Thu, Nov 23, 2006 at 02:17:03AM -0800, Andrew Morton wrote:
> >...
> > Changes since 2.6.19-rc5-mm2:
> >...
> > +chelsio-22-driver.patch
> >...
> >  netdev updates
> 
> It is suspicious that the following newly added code is completely unused:
>   drivers/net/chelsio/ixf1010.o
>     t1_ixf1010_ops
>   drivers/net/chelsio/mac.o
>     t1_chelsio_mac_ops
>   drivers/net/chelsio/vsc8244.o
>     t1_vsc8244_ops
> 
> cu
> Adrian
> 

All that is gone in later version. I reposted new patches
after -mm2 was done.
