From: Rob Herring <robh@kernel.org>
Subject: Re: [PATCH] Make EN2 pin optional in the TRF7970A driver
Date: Fri, 10 Feb 2017 09:51:14 -0600
Message-ID: <20170210155114.pvjahqqjqurw5jdc@rob-hp-laptop>
References: <1486444924-18444-1-git-send-email-hs@denx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, Guan Ben <ben.guan@cn.bosch.com>,
        Mark Jonas <mark.jonas@de.bosch.com>,
        devicetree@vger.kernel.org, linux-wireless@vger.kernel.org,
        linux-kernel@vger.kernel.org, Samuel Ortiz <sameo@linux.intel.com>,
        Lauro Ramos Venancio <lauro.venancio@openbossa.org>,
        Aloisio Almeida Jr <aloisio.almeida@openbossa.org>,
        Mark Rutland <mark.rutland@arm.com>
To: Heiko Schocher <hs@denx.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f67.google.com ([209.85.218.67]:34712 "EHLO
        mail-oi0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752351AbdBJPzy (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 10 Feb 2017 10:55:54 -0500
Content-Disposition: inline
In-Reply-To: <1486444924-18444-1-git-send-email-hs@denx.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 07, 2017 at 06:22:04AM +0100, Heiko Schocher wrote:
> From: Guan Ben <ben.guan@cn.bosch.com>
> 
> Make the EN2 pin optional. This is useful for boards,
> which have this pin fix wired, for example to ground.
> 
> Signed-off-by: Guan Ben <ben.guan@cn.bosch.com>
> Signed-off-by: Mark Jonas <mark.jonas@de.bosch.com>
> Signed-off-by: Heiko Schocher <hs@denx.de>
> 
> ---
> 
>  .../devicetree/bindings/net/nfc/trf7970a.txt       |  4 ++--
>  drivers/nfc/trf7970a.c                             | 26 ++++++++++++----------
>  2 files changed, 16 insertions(+), 14 deletions(-)
> 
> diff --git a/Documentation/devicetree/bindings/net/nfc/trf7970a.txt b/Documentation/devicetree/bindings/net/nfc/trf7970a.txt
> index 32b35a0..5889a3d 100644
> --- a/Documentation/devicetree/bindings/net/nfc/trf7970a.txt
> +++ b/Documentation/devicetree/bindings/net/nfc/trf7970a.txt
> @@ -5,8 +5,8 @@ Required properties:
>  - spi-max-frequency: Maximum SPI frequency (<= 2000000).
>  - interrupt-parent: phandle of parent interrupt handler.
>  - interrupts: A single interrupt specifier.
> -- ti,enable-gpios: Two GPIO entries used for 'EN' and 'EN2' pins on the
> -  TRF7970A.
> +- ti,enable-gpios: One or two GPIO entries used for 'EN' and 'EN2' pins on the
> +  TRF7970A. EN2 is optional.

Could EN ever be optional/fixed? If so, perhaps deprecate this property 
and do 2 properties, one for each pin.

Rob
