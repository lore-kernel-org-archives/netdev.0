From: Rob Herring <robh@kernel.org>
Subject: Re: [PATCH 4/8] tty/bcm63xx_uart: allow naming clock in device tree
Date: Thu, 10 Aug 2017 11:25:15 -0500
Message-ID: <20170810162515.qkmhcnsaoh4wjrzs@rob-hp-laptop>
References: <20170802093429.12572-1-jonas.gorski@gmail.com>
 <20170802093429.12572-5-jonas.gorski@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-mips@linux-mips.org, linux-arm-kernel@lists.infradead.org,
        linux-serial@vger.kernel.org, devicetree@vger.kernel.org,
        netdev@vger.kernel.org,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Mark Rutland <mark.rutland@arm.com>,
        Ralf Baechle <ralf@linux-mips.org>,
        Florian Fainelli <f.fainelli@gmail.com>,
        bcm-kernel-feedback-list@broadcom.com,
        Kevin Cernekee <cernekee@gmail.com>,
        Jiri Slaby <jslaby@suse.com>,
        "David S. Miller" <davem@davemloft.net>,
        Russell King <linux@armlinux.org.uk>
To: Jonas Gorski <jonas.gorski@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f66.google.com ([74.125.83.66]:33690 "EHLO
        mail-pg0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753133AbdHJQZR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 10 Aug 2017 12:25:17 -0400
Content-Disposition: inline
In-Reply-To: <20170802093429.12572-5-jonas.gorski@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 02, 2017 at 11:34:25AM +0200, Jonas Gorski wrote:
> Codify using a named clock for the refclk of the uart. This makes it
> easier if we might need to add a gating clock (like present on the
> BCM6345).
> 
> Signed-off-by: Jonas Gorski <jonas.gorski@gmail.com>
> ---
>  Documentation/devicetree/bindings/serial/brcm,bcm6345-uart.txt | 6 ++++++
>  drivers/tty/serial/bcm63xx_uart.c                              | 6 ++++--
>  2 files changed, 10 insertions(+), 2 deletions(-)

Acked-by: Rob Herring <robh@kernel.org>
