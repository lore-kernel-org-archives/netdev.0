From: <Woojung.Huh@microchip.com>
Subject: RE: [PATCH net] net: dsa: ksz: fix skb freeing
Date: Wed, 9 Aug 2017 21:43:39 +0000
Message-ID: <9235D6609DB808459E95D78E17F2E43D40AF7B16@CHN-SV-EXMX02.mchp-main.com>
References: <20170809204609.8114-1-vivien.didelot@savoirfairelinux.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <linux-kernel@vger.kernel.org>, <kernel@savoirfairelinux.com>,
        <davem@davemloft.net>, <f.fainelli@gmail.com>, <andrew@lunn.ch>
To: <vivien.didelot@savoirfairelinux.com>, <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170809204609.8114-1-vivien.didelot@savoirfairelinux.com>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> The DSA layer frees the original skb when an xmit function returns NULL,
> meaning an error occurred. But if the tagging code copied the original
> skb, it is responsible of freeing the copy if an error occurs.
> 
> The ksz tagging code currently has two issues: if skb_put_padto fails,
> the skb copy is not freed, and the original skb will be freed twice.
> 
> To fix that, move skb_put_padto inside both branches of the skb_tailroom
> condition, before freeing the original skb, and free the copy on error.
> 
> Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Reviewed-by: Woojung Huh <woojung.huh@microchip.com>
