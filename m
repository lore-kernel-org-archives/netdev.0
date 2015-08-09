From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCHv2 net-next] dsa: Support multiple MDIO busses
Date: Sun, 9 Aug 2015 15:39:25 +0300
Message-ID: <55C749FD.8050303@cogentembedded.com>
References: <1439083745-14169-1-git-send-email-andrew@lunn.ch>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	netdev <netdev@vger.kernel.org>
To: Andrew Lunn <andrew@lunn.ch>, David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f176.google.com ([209.85.217.176]:32876 "EHLO
	mail-lb0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932986AbbHIMj2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Aug 2015 08:39:28 -0400
Received: by lbbyj8 with SMTP id yj8so82341311lbb.0
        for <netdev@vger.kernel.org>; Sun, 09 Aug 2015 05:39:27 -0700 (PDT)
In-Reply-To: <1439083745-14169-1-git-send-email-andrew@lunn.ch>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 8/9/2015 4:29 AM, Andrew Lunn wrote:

> When using a cluster of switches, some topologies will have an MDIO
> bus per switch, not one for the whole cluster. Allow this to be
> represented in the device tree, by adding an optional mii-bus property
> at the switch level.

> Signed-off-by: Andrew Lunn <andrew@lunn.ch>
> Reviewed-by: Florian Fainelli <f.fainelli@gmail.com>
> ---
>
> v2: Fix documentation, which placed the properties documentation in
>      the wrong place.
> ---
>   Documentation/devicetree/bindings/net/dsa/dsa.txt |  5 +++++
>   net/dsa/dsa.c                                     | 12 +++++++++++-
>   2 files changed, 16 insertions(+), 1 deletion(-)

> diff --git a/Documentation/devicetree/bindings/net/dsa/dsa.txt b/Documentation/devicetree/bindings/net/dsa/dsa.txt
> index f0b4cd72411d..fc06f4a7c788 100644
> --- a/Documentation/devicetree/bindings/net/dsa/dsa.txt
> +++ b/Documentation/devicetree/bindings/net/dsa/dsa.txt
> @@ -32,6 +32,10 @@ A switch child node has the following optional property:
>   			  the presence and/or size of a connected EEPROM,
>   			  otherwise optional.
>
> +- mii-bus		: Should be a phandle to a valid MDIO bus device node.

    Why not call it "mdio-bus"?

> +			  This mii-bus will be used in preference to the
> +			  global dsa,mii-bus defined above, for this switch.
> +
>   A switch may have multiple "port" children nodes
>
>   Each port children node must have the following mandatory properties:
[...]

MBR, Sergei
