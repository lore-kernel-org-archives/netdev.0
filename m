From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 2.6.11 7/8] tg3: Fix ethtool set functions
Date: Tue, 22 Mar 2005 15:59:05 -0500
Message-ID: <42408719.5000307@pobox.com>
References: <B1508D50A0692F42B217C22C02D84972020F3E27@NT-IRVA-0741.brcm.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@oss.sgi.com
To: Michael Chan <mchan@broadcom.com>
In-Reply-To: <B1508D50A0692F42B217C22C02D84972020F3E27@NT-IRVA-0741.brcm.ad.broadcom.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Michael Chan wrote:
> Fix all relevant ethtool set functions to properly handle the
> !netif_running() case. In most cases, the new settings are accepted without
> setting the hardware if !netif_running(). The new settings will take effect
> when the device is subsequently brought up. tg3_nway_reset() is the exception
> where it will return -EAGAIN if !netif_running().
> 
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com

ACK
