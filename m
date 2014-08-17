From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] net: phy: smsc: move smsc_phy_config_init reset
 part in a soft_reset function
Date: Sat, 16 Aug 2014 20:16:29 -0700 (PDT)
Message-ID: <20140816.201629.1009178063004110712.davem@davemloft.net>
References: <1408107638-96143-1-git-send-email-gwenhael.goavec-merou@armadeus.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, f.fainelli@gmail.com,
	netdev@vger.kernel.org
To: gwenhael.goavec-merou@armadeus.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1408107638-96143-1-git-send-email-gwenhael.goavec-merou@armadeus.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Gwenhael Goavec-Merou <gwenhael.goavec-merou@armadeus.com>
Date: Fri, 15 Aug 2014 15:00:38 +0200

> On the one hand, phy_device.c provides a generic reset function if the phy
> driver does not provide a soft_reset pointer. This generic reset does not take
> into account the state of the phy, with a potential failure if the phy is in
> powerdown mode. On the other hand, smsc driver provides a function with both
> correct reset behaviour and configuration.
> 
> This patch moves the reset part into a new smsc_phy_reset function and provides
> the soft_reset pointer to have a correct reset behaviour by default.
> 
> Signed-off-by: Gwenhael Goavec-Merou <gwenhael.goavec-merou@armadeus.com>

Applied, thanks.
