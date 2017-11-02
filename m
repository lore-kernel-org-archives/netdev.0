From: Shawn Guo <shawn.guo@linaro.org>
Subject: Re: [PATCH net v4 1/2] imx7s/imx7d has the ptp interrupt newly added
 as well.
Date: Thu, 2 Nov 2017 12:12:13 +0800
Message-ID: <CAAQ0ZWS7gveLQ61102D_Rv41SuE_48FzmtjP-9i1Mm0cBK-P_w@mail.gmail.com>
References: <20171031201647.13006-1-troy.kisky@boundarydevices.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: fugang.duan@nxp.com, Linux Netdev List <netdev@vger.kernel.org>,
        David Miller <davem@davemloft.net>, fabio.estevam@nxp.com,
        Zhi Li <lznuaa@gmail.com>, Andrew Lunn <andrew@lunn.ch>
To: Troy Kisky <troy.kisky@boundarydevices.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f194.google.com ([209.85.217.194]:43615 "EHLO
        mail-ua0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750753AbdKBEMO (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 2 Nov 2017 00:12:14 -0400
Received: by mail-ua0-f194.google.com with SMTP id u32so3049028uau.0
        for <netdev@vger.kernel.org>; Wed, 01 Nov 2017 21:12:14 -0700 (PDT)
In-Reply-To: <20171031201647.13006-1-troy.kisky@boundarydevices.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Nov 1, 2017 at 4:16 AM, Troy Kisky
<troy.kisky@boundarydevices.com> wrote:
> For imx7, "int0" is the interrupt for queue 0 and ENET_MII
> "int1" is for queue 1
> "int2" is for queue 2
>
> For imx6sx, "int0" handles all 3 queues and ENET_MII
>
> And of course, the "pps" interrupt is for the PTP_CLOCK_PPS interrupts
> This will help document what each interrupt does.
>
> Signed-off-by: Troy Kisky <troy.kisky@boundarydevices.com>

I had updated my email address in MAINTAINERS for years.  Please use that one.

> v4: add blank, ie s/"int0","pps"/"int0", "pps"/ as suggested by Andrew Lunn
> ---
>  Documentation/devicetree/bindings/net/fsl-fec.txt | 13 +++++++++++++

Please have bindings go with net driver instead of DTS changes.

Shawn

>  arch/arm/boot/dts/imx6qdl.dtsi                    |  1 +
>  arch/arm/boot/dts/imx6sx.dtsi                     |  2 ++
>  arch/arm/boot/dts/imx6ul.dtsi                     |  2 ++
>  arch/arm/boot/dts/imx7d.dtsi                      |  6 ++++--
>  arch/arm/boot/dts/imx7s.dtsi                      |  6 ++++--
>  6 files changed, 26 insertions(+), 4 deletions(-)
