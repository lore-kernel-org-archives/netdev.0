From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 2.6.11 7/8] tg3: Fix ethtool set functions
Date: Wed, 23 Mar 2005 11:14:21 -0800
Message-ID: <20050323111421.372c20a3.davem@davemloft.net>
References: <B1508D50A0692F42B217C22C02D84972020F3E27@NT-IRVA-0741.brcm.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com
To: "Michael Chan" <mchan@broadcom.com>
In-Reply-To: <B1508D50A0692F42B217C22C02D84972020F3E27@NT-IRVA-0741.brcm.ad.broadcom.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Mon, 21 Mar 2005 00:13:07 -0800
"Michael Chan" <mchan@broadcom.com> wrote:

> Fix all relevant ethtool set functions to properly handle the
> !netif_running() case. In most cases, the new settings are accepted without
> setting the hardware if !netif_running(). The new settings will take effect
> when the device is subsequently brought up. tg3_nway_reset() is the exception
> where it will return -EAGAIN if !netif_running().
> 
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied, thanks Michael.
