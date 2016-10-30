From: Rob Herring <robh@kernel.org>
Subject: Re: [RFC PATCH 01/13] pinctrl: meson: Add GXL pinctrl definitions
Date: Sun, 30 Oct 2016 15:41:26 -0500
Message-ID: <20161030204126.adj4bo7arpxxqtpf@rob-hp-laptop>
References: <1477060838-14164-1-git-send-email-narmstrong@baylibre.com>
 <1477060838-14164-2-git-send-email-narmstrong@baylibre.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: khilman@baylibre.com, carlo@caione.org, linus.walleij@linaro.org,
        linux-gpio@vger.kernel.org, devicetree@vger.kernel.org,
        linux-arm-kernel@lists.infradead.org,
        linux-amlogic@lists.infradead.org, linux-kernel@vger.kernel.org,
        netdev@vger.kernel.org
To: Neil Armstrong <narmstrong@baylibre.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f66.google.com ([209.85.218.66]:36420 "EHLO
        mail-oi0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755208AbcJ3Ul2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sun, 30 Oct 2016 16:41:28 -0400
Content-Disposition: inline
In-Reply-To: <1477060838-14164-2-git-send-email-narmstrong@baylibre.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Oct 21, 2016 at 04:40:26PM +0200, Neil Armstrong wrote:
> Add support for the Amlogic Meson GXL SoC, this is a partially complete
> definition only based on the Amlogic Vendor tree.
> 
> This definition differs a lot from the GXBB and needs a separate entry.
> 
> Signed-off-by: Neil Armstrong <narmstrong@baylibre.com>
> ---
>  .../devicetree/bindings/pinctrl/meson,pinctrl.txt  |   2 +

Acked-by: Rob Herring <robh@kernel.org>

>  drivers/pinctrl/meson/Makefile                     |   3 +-
>  drivers/pinctrl/meson/pinctrl-meson-gxl.c          | 589 +++++++++++++++++++++
>  drivers/pinctrl/meson/pinctrl-meson.c              |   8 +
>  drivers/pinctrl/meson/pinctrl-meson.h              |   2 +
>  include/dt-bindings/gpio/meson-gxl-gpio.h          | 131 +++++
>  6 files changed, 734 insertions(+), 1 deletion(-)
>  create mode 100644 drivers/pinctrl/meson/pinctrl-meson-gxl.c
>  create mode 100644 include/dt-bindings/gpio/meson-gxl-gpio.h
