From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH RFC 1/2] Documentation: add Device tree bindings for QCA7000
Date: Mon, 28 Apr 2014 21:57:23 +0200
Message-ID: <4257797.n2vaSiS5NN@wuerfel>
References: <1398707697-43785-1-git-send-email-stefan.wahren@i2se.com> <1398707697-43785-2-git-send-email-stefan.wahren@i2se.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: davem@davemloft.net, robh+dt@kernel.org, pawel.moll@arm.org,
	mark.rutland@arm.org, ijc+devicetree@hellion.org.uk,
	galak@codeaurora.org, f.fainelli@gmail.com, netdev@vger.kernel.org,
	devicetree@vger.kernel.org
To: Stefan Wahren <stefan.wahren@i2se.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mout.kundenserver.de ([212.227.17.13]:54920 "EHLO
	mout.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754708AbaD1T5c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Apr 2014 15:57:32 -0400
In-Reply-To: <1398707697-43785-2-git-send-email-stefan.wahren@i2se.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 28 April 2014 19:54:56 Stefan Wahren wrote:
> This patch adds the Device tree bindings for the Ethernet over SPI
> protocol driver of the Qualcomm QCA7000 HomePlug GreenPHY.
> 
> Signed-off-by: Stefan Wahren <stefan.wahren@i2se.com>
> ---
>  .../devicetree/bindings/net/qca-qca7000-spi.txt    |   51 ++++++++++++++++++++
>  1 file changed, 51 insertions(+)
>  create mode 100644 Documentation/devicetree/bindings/net/qca-qca7000-spi.txt
> 
> diff --git a/Documentation/devicetree/bindings/net/qca-qca7000-spi.txt b/Documentation/devicetree/bindings/net/qca-qca7000-spi.txt
> new file mode 100644
> index 0000000..132c10f
> --- /dev/null
> +++ b/Documentation/devicetree/bindings/net/qca-qca7000-spi.txt
> @@ -0,0 +1,51 @@
> +* Qualcomm QCA7000 (Ethernet over SPI protocol)
> +
> +Note: The QCA7000 is useable as a SPI device. In this case it must be defined
> +as a child of a spi master in the device tree.
> +
> +Required properties:
> +- compatible : Should be "qca,qca7000"
> +- reg : Should specify the SPI chip select
> +- intr-gpios : Should specify the GPIO for SPI interrupt
> +- spi-cpha : Must be set
> +- spi-cpol: Must be set

Why specify the interrupt as a GPIO line, rather than an 'interrupts' property?

	Arnd
