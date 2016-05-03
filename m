From: Rob Herring <robh@kernel.org>
Subject: Re: [PATCH v5 1/2] can: rcar_canfd: Add Renesas R-Car CAN FD driver
Date: Tue, 3 May 2016 11:47:28 -0500
Message-ID: <20160503164728.GA32640@rob-hp-laptop>
References: <1456824849-7987-1-git-send-email-ramesh.shanmugasundaram@bp.renesas.com>
 <1461846188-31249-1-git-send-email-ramesh.shanmugasundaram@bp.renesas.com>
 <1461846188-31249-2-git-send-email-ramesh.shanmugasundaram@bp.renesas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: mkl@pengutronix.de, wg@grandegger.com, socketcan@hartkopp.net,
	pawel.moll@arm.com, mark.rutland@arm.com,
	ijc+devicetree@hellion.org.uk, galak@codeaurora.org,
	linux-renesas-soc@vger.kernel.org, devicetree@vger.kernel.org,
	linux-can@vger.kernel.org, netdev@vger.kernel.org,
	chris.paterson2@renesas.com
To: Ramesh Shanmugasundaram <ramesh.shanmugasundaram@bp.renesas.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:41594 "EHLO mail.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756047AbcECQrj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 May 2016 12:47:39 -0400
Content-Disposition: inline
In-Reply-To: <1461846188-31249-2-git-send-email-ramesh.shanmugasundaram@bp.renesas.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 28, 2016 at 01:23:07PM +0100, Ramesh Shanmugasundaram wrote:
> This patch adds support for the CAN FD controller found in Renesas R-Car
> SoCs. The controller operates in CAN FD only mode by default.
> 
> CAN FD mode supports both Classical CAN & CAN FD frame formats. The
> controller supports ISO 11898-1:2015 CAN FD format only.
> 
> This controller supports two channels and the driver can enable either
> or both of the channels.
> 
> Driver uses Rx FIFOs (one per channel) for reception & Common FIFOs (one
> per channel) for transmission. Rx filter rules are configured to the
> minimum (one per channel) and it accepts Standard, Extended, Data &
> Remote Frame combinations.
> 
> Note: There are few documentation errors in R-Car Gen3 Hardware User
> Manual v0.5E with respect to CAN FD controller. They are listed below:
> 
> 1. CAN FD interrupt numbers 29 & 30 are listed as per channel
> interrupts. However, they are common to both channels (i.e.) they are
> global and channel interrupts respectively.
> 
> 2. CANFD clock is derived from PLL1. This is not documented.
> 
> 3. CANFD clock is further divided by (1/2) within the CAN FD controller.
> This is not documented.
> 
> 4. The minimum value of NTSEG1 in RSCFDnCFDCmNCFG register is 2 Tq. It
> is specified 4 Tq in the manual.
> 
> 5. The maximum number of message RAM area the controller can use is 3584
> bytes. It is specified 10752 bytes in the manual.
> 
> Signed-off-by: Ramesh Shanmugasundaram <ramesh.shanmugasundaram@bp.renesas.com>
> ---
>  .../devicetree/bindings/net/can/rcar_canfd.txt     |   89 ++

What happened to my ack?

>  drivers/net/can/Kconfig                            |    1 +
>  drivers/net/can/Makefile                           |    1 +
>  drivers/net/can/rcar/Kconfig                       |   11 +
>  drivers/net/can/rcar/Makefile                      |    5 +
>  drivers/net/can/rcar/rcar_canfd.c                  | 1624 ++++++++++++++++++++
>  6 files changed, 1731 insertions(+)
>  create mode 100644 Documentation/devicetree/bindings/net/can/rcar_canfd.txt
>  create mode 100644 drivers/net/can/rcar/Kconfig
>  create mode 100644 drivers/net/can/rcar/Makefile
>  create mode 100644 drivers/net/can/rcar/rcar_canfd.c
