From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH net-next v4 12/13] Documentation: devicetree: update dsa
 binding with optional properties
Date: Wed, 27 Aug 2014 02:40:34 +0400
Message-ID: <53FD0CE2.4010101@cogentembedded.com>
References: <1409028581-17399-1-git-send-email-f.fainelli@gmail.com> <1409028581-17399-13-git-send-email-f.fainelli@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, linville@tuxdriver.com, jhs@mojatatu.com,
	alexander.duyck@gmail.com
To: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f170.google.com ([209.85.217.170]:55392 "EHLO
	mail-lb0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756052AbaHZWki (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Aug 2014 18:40:38 -0400
Received: by mail-lb0-f170.google.com with SMTP id p9so2195247lbv.15
        for <netdev@vger.kernel.org>; Tue, 26 Aug 2014 15:40:36 -0700 (PDT)
In-Reply-To: <1409028581-17399-13-git-send-email-f.fainelli@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 08/26/2014 08:49 AM, Florian Fainelli wrote:

> Add documentation for a bunch of new optional properties described in
> ethernet.txt and fixed-link.txt, this includes: 'phy-handle', 'phy-mode'
> and the 'fixed-link' subnode.

> Signed-off-by: Florian Fainelli <f.fainelli@gmail.com>
> ---
>   Documentation/devicetree/bindings/net/dsa/dsa.txt | 17 +++++++++++++++++
>   1 file changed, 17 insertions(+)

> diff --git a/Documentation/devicetree/bindings/net/dsa/dsa.txt b/Documentation/devicetree/bindings/net/dsa/dsa.txt
> index 49f4f7ae3f51..6192f9a7aa89 100644
> --- a/Documentation/devicetree/bindings/net/dsa/dsa.txt
> +++ b/Documentation/devicetree/bindings/net/dsa/dsa.txt
> @@ -39,6 +39,22 @@ Optionnal property:
>   			  This property is only used when switches are being
>   			  chained/cascaded together.
>
> +- phy-handle		: Phandle to a PHY on an external MDIO bus, not the
> +			  switch internal one. See
> +			  Documentation/devicetree/bindings/net/ethernet.txt
> +			  for details.
> +
> +- phy-mode		: String representing the connection to the designeted

    Designated?

> +			  PHY node specified by the 'phy-handle' property. See
> +			  Documentation/devicetree/bindings/net/ethernet.txt
> +			  for details.
> +
> +Optionnal subnodes:

    One 'n' is enough (although DaveM may disagree ;-).

WBR, Sergei
