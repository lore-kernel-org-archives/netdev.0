From: Florian Fainelli <florian@openwrt.org>
Subject: Re: [PATCH 2/2 net-next-2.6] au1000-eth: convert to platform_driver model
Date: Mon, 9 Nov 2009 11:18:05 +0100
Message-ID: <200911091118.05245.florian@openwrt.org>
References: <200911081542.12219.florian@openwrt.org> <20091108.210236.247950385.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linux-mips@linux-mips.org, ralf@linux-mips.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f207.google.com ([209.85.219.207]:36501 "EHLO
	mail-ew0-f207.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751167AbZKIKSu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Nov 2009 05:18:50 -0500
Received: by ewy3 with SMTP id 3so2943118ewy.37
        for <netdev@vger.kernel.org>; Mon, 09 Nov 2009 02:18:55 -0800 (PST)
In-Reply-To: <20091108.210236.247950385.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi David, Ralf,

On Monday 09 November 2009 06:02:36 David Miller wrote:
> From: Florian Fainelli <florian@openwrt.org>
> Date: Sun, 8 Nov 2009 15:42:11 +0100
> 
> > This patch converts the au1000-eth driver to become a full
> > platform-driver as it ought to be. We now pass PHY-speficic
> > configurations through platform_data but for compatibility
> > the driver still assumes the default settings (search for PHY1 on
> > MAC0) when no platform_data is passed. Tested on my MTX-1 board.
> >
> > Signed-off-by: Florian Fainelli <florian@openwrt.org>
> 
> Ralf, feel free to merge this yourself since it depends upon
> the previous Alchemy platform patch:
> 
> Acked-by: David S. Miller <davem@davemloft.net>

Thank you David. I will do a follow up patch which cleans up the driver once 
that one gets merged.
