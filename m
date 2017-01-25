From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v4] net: ethernet: faraday: To support device tree
 usage.
Date: Wed, 25 Jan 2017 12:34:48 -0500 (EST)
Message-ID: <20170125.123448.742815192519658537.davem@davemloft.net>
References: <20170124084606.GA11764@app09>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, devicetree@vger.kernel.org, andrew@lunn.ch,
        arnd@arndb.de, jiri@resnulli.us, linux-kernel@vger.kernel.org,
        f.fainelli@gmail.com, robh+dt@kernel.org, mark.rutland@arm.com
To: green.hu@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170124084606.GA11764@app09>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Greentime Hu <green.hu@gmail.com>
Date: Tue, 24 Jan 2017 16:46:14 +0800

> We also use the same binding document to describe the same faraday ethernet
> controller and add faraday to vendor-prefixes.txt.
> 
> Signed-off-by: Greentime Hu <green.hu@gmail.com>
> ---
> Changes in v4:
>   - Use the same binding document to describe the same faraday ethernet controller and add faraday to vendor-prefixes.txt.
> Changes in v3:
>   - Nothing changed in this patch but I have committed andestech to vendor-prefixes.txt.
> Changes in v2:
>   - Change atmac100_of_ids to ftmac100_of_ids
> 
> ---
>  .../net/{moxa,moxart-mac.txt => faraday,ftmac.txt} |    7 +++++--
>  .../devicetree/bindings/vendor-prefixes.txt        |    1 +
>  drivers/net/ethernet/faraday/ftmac100.c            |    7 +++++++
>  3 files changed, 13 insertions(+), 2 deletions(-)
>  rename Documentation/devicetree/bindings/net/{moxa,moxart-mac.txt => faraday,ftmac.txt} (68%)
> 
> diff --git a/Documentation/devicetree/bindings/net/moxa,moxart-mac.txt b/Documentation/devicetree/bindings/net/faraday,ftmac.txt
> similarity index 68%
> rename from Documentation/devicetree/bindings/net/moxa,moxart-mac.txt
> rename to Documentation/devicetree/bindings/net/faraday,ftmac.txt

Why are you renaming the MOXA binding file instead of adding a completely new one
for faraday?  The MOXA one should stick around, I don't see a justification for
removing it.
