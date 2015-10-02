From: Neil Armstrong <narmstrong@baylibre.com>
Subject: Re: [PATCH 0/3] net: dsa: Complete and fix the dsa unbinding
Date: Fri, 2 Oct 2015 14:11:28 +0200
Message-ID: <560E7470.4080505@baylibre.com>
References: <560E60DF.4000505@baylibre.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, andrew@lunn.ch,
	Guenter Roeck <linux@roeck-us.net>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <560E60DF.4000505@baylibre.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 10/02/2015 12:47 PM, Neil Armstrong wrote:
> In order to cleanly unbind the dsa core, either as a module removal,
> or a platform device unbind, switch the allocation the their devm_
> counterparts and complete the destroy functions.
> 
> The last patch is an experimental way to exit the probe when no
> switch is found in the discover process.
> 
> The patches are based on the current net-next.
> 
> Tested-by: Andrew Lunn <andrew@lunn.ch>
> Tested-by: Florian Fainelli <f.fainelli@gmail.com>
> 
> Neil Armstrong (3):
>   net: dsa: Use devm_ prefixed allocations
>   net: dsa: complete dsa_switch_destroy calls
>   net: dsa: exit probe if no switch were found
> 
>  net/dsa/dsa.c | 67 ++++++++++++++++++++++++++++++++++++++++++++++++++++-------
>  1 file changed, 60 insertions(+), 7 deletions(-)
> 
Hi,

Sorry, I forgot to update the CC list, my bad.

I still hope this serie will be applied.

Regards,
Neil
