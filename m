From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] r8152: restore hw settings
Date: Sat, 14 Feb 2015 20:16:17 -0800 (PST)
Message-ID: <20150214.201617.380649779582234752.davem@davemloft.net>
References: <1394712342-15778-145-Taiwan-albertk@realtek.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nic_swsd@realtek.com,
	linux-kernel@vger.kernel.org, linux-usb@vger.kernel.org
To: hayeswang@realtek.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1394712342-15778-145-Taiwan-albertk@realtek.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Hayes Wang <hayeswang@realtek.com>
Date: Thu, 12 Feb 2015 16:20:46 +0800

> There is a capability which let the hw could change the settings
> automatically when the power change to ON. However, the USB reset
> would reset the settings to the hw default, so the driver has to
> restore the relative settings. Otherwise, it would influence the
> functions of the hw, and the compatibility for the USB hub and
> USB host controller.
> 
> The relative settings are as following.
>  - set the power down scale to 96.
>  - enable the power saving function of USB 2.0.
>  - disable the ALDPS of ECM mode.
>  - set burst mode depending on the burst size.
>  - enable the flow control of endpoint full.
>  - set fifo empty boundary to 32448 bytes.
>  - enable the function of exiting LPM when Rx OK occurs.
>  - set the connect timer to 1.
> 
> Signed-off-by: Hayes Wang <hayeswang@realtek.com>

Applied.
