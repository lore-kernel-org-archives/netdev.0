From: Adrian Bunk <bunk@stusta.de>
Subject: 2.6.19-rc6-mm1: drivers/net/chelsio/: unused code
Date: Fri, 24 Nov 2006 01:17:31 +0100
Message-ID: <20061124001731.GO3557@stusta.de>
References: <20061123021703.8550e37e.akpm@osdl.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, Jeff Garzik <jeff@garzik.org>,
	netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout.stusta.mhn.de ([141.84.69.5]:55816 "HELO
	mailout.stusta.mhn.de") by vger.kernel.org with SMTP
	id S1757524AbWKXAR2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Nov 2006 19:17:28 -0500
To: Andrew Morton <akpm@osdl.org>,
	Stephen Hemminger <shemminger@osdl.org>
Content-Disposition: inline
In-Reply-To: <20061123021703.8550e37e.akpm@osdl.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Nov 23, 2006 at 02:17:03AM -0800, Andrew Morton wrote:
>...
> Changes since 2.6.19-rc5-mm2:
>...
> +chelsio-22-driver.patch
>...
>  netdev updates

It is suspicious that the following newly added code is completely unused:
  drivers/net/chelsio/ixf1010.o
    t1_ixf1010_ops
  drivers/net/chelsio/mac.o
    t1_chelsio_mac_ops
  drivers/net/chelsio/vsc8244.o
    t1_vsc8244_ops

cu
Adrian

-- 

       "Is there not promise of rain?" Ling Tan asked suddenly out
        of the darkness. There had been need of rain for many days.
       "Only a promise," Lao Er said.
                                       Pearl S. Buck - Dragon Seed

