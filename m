From: Sergei Shtylyov <sshtylyov@mvista.com>
Subject: Re: [PATCH 02/50] smsc95xx: use dev_hw_addr_random() instead of random_ether_addr()
Date: Thu, 09 Feb 2012 14:51:44 +0400
Message-ID: <4F33A540.7020906@mvista.com>
References: <1328735457-29986-1-git-send-email-danny.kukawka@bisect.de> <1328735457-29986-3-git-send-email-danny.kukawka@bisect.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Danny Kukawka <dkukawka@suse.de>,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Steve Glendinning <steve.glendinning@smsc.com>,
	linux-usb@vger.kernel.org, linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
To: Danny Kukawka <danny.kukawka@bisect.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1328735457-29986-3-git-send-email-danny.kukawka@bisect.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 09-02-2012 1:10, Danny Kukawka wrote:

> Use dev_hw_addr_random() instead of calling random_ether_addr()
> to set addr_assign_type correctly to NET_ADDR_RANDOM.

> Signed-off-by: Danny Kukawka<danny.kukawka@bisect.de>
> ---
>   drivers/net/usb/smsc95xx.c |    2 +-
>   1 files changed, 1 insertions(+), 1 deletions(-)

> diff --git a/drivers/net/usb/smsc95xx.c b/drivers/net/usb/smsc95xx.c
> index d45520e..3a28e95 100644
> --- a/drivers/net/usb/smsc95xx.c
> +++ b/drivers/net/usb/smsc95xx.c
> @@ -614,7 +614,7 @@ static void smsc95xx_init_mac_address(struct usbnet *dev)
>   	}
>
>   	/* no eeprom, or eeprom values are invalid. generate random MAC */
> -	random_ether_addr(dev->net->dev_addr);
> +	dev_hw_addr_random(dev->net , dev->net->dev_addr);

    Should be no space before comma.

WBR, Sergei
