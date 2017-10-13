From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH net-next v2 2/4] net: dsa: mv88e6060: setup random mac
 address
Date: Fri, 13 Oct 2017 15:30:41 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DD0094F25@AcuExch.aculab.com>
References: <20171013014113.29561-1-vivien.didelot@savoirfairelinux.com>
 <20171013014113.29561-3-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "kernel@savoirfairelinux.com" <kernel@savoirfairelinux.com>,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>
To: 'Vivien Didelot' <vivien.didelot@savoirfairelinux.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171013014113.29561-3-vivien.didelot@savoirfairelinux.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vivien Didelot
> Sent: 13 October 2017 02:41
> As for mv88e6xxx, setup the switch from within the mv88e6060 driver with
> a random MAC address, and remove the .set_addr implementation.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
> ---
>  drivers/net/dsa/mv88e6060.c | 30 +++++++++++++++++++-----------
>  1 file changed, 19 insertions(+), 11 deletions(-)
> 
> diff --git a/drivers/net/dsa/mv88e6060.c b/drivers/net/dsa/mv88e6060.c
> index 621cdc46ad81..2f9d5e6a0f97 100644
> --- a/drivers/net/dsa/mv88e6060.c
> +++ b/drivers/net/dsa/mv88e6060.c
...
> +	REG_WRITE(REG_GLOBAL, GLOBAL_MAC_01, (addr[0] << 9) | addr[1]);

Is that supposed to be 9 ?

	David
