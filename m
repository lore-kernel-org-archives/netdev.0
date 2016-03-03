From: Rob Herring <robh@kernel.org>
Subject: Re: [PATCH] can: rcar_can: Add r8a7795 support
Date: Thu, 3 Mar 2016 16:22:57 -0600
Message-ID: <20160303222257.GA5346@rob-hp-laptop>
References: <1456749445-50766-1-git-send-email-ramesh.shanmugasundaram@bp.renesas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: mkl@pengutronix.de, wg@grandegger.com, pawel.moll@arm.com,
	mark.rutland@arm.com, ijc+devicetree@hellion.org.uk,
	galak@codeaurora.org, linux-renesas-soc@vger.kernel.org,
	devicetree@vger.kernel.org, linux-can@vger.kernel.org,
	netdev@vger.kernel.org, geert+renesas@glider.be,
	horms+renesas@verge.net.au, chris.paterson2@renesas.com
To: Ramesh Shanmugasundaram <ramesh.shanmugasundaram@bp.renesas.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:40314 "EHLO mail.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757437AbcCCWXD (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Mar 2016 17:23:03 -0500
Content-Disposition: inline
In-Reply-To: <1456749445-50766-1-git-send-email-ramesh.shanmugasundaram@bp.renesas.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 29, 2016 at 12:37:25PM +0000, Ramesh Shanmugasundaram wrote:
> Added r8a7795 SoC support.
> 
> Signed-off-by: Ramesh Shanmugasundaram <ramesh.shanmugasundaram@bp.renesas.com>
> ---
> Hi All,
> 
>    This patch is based on linux-can-next (tag:linux-can-next-for-4.6-20160226)
> 
>    Pinctrl & Clock related to the controller are already submitted as below:
> 
>    https://lkml.org/lkml/2016/2/25/546
>    https://lkml.org/lkml/2016/2/26/452
>    http://www.spinics.net/lists/arm-kernel/msg487238.html
> 
>    Changes since v1:
>    * Rebased from linux-next to linux-can-next
>    * Removed clock rounding hack (http://www.spinics.net/lists/netdev/msg366611.html)
>    * CAN dtsi changes will be submitted separately based on linux-next (http://marc.info/?l=linux-can&m=145674764815430&w=2)
> 
>  Documentation/devicetree/bindings/net/can/rcar_can.txt | 11 +++++++++++
>  drivers/net/can/Kconfig                                |  2 +-
>  drivers/net/can/rcar_can.c                             |  1 +
>  3 files changed, 13 insertions(+), 1 deletion(-)

Acked-by: Rob Herring <robh@kernel.org>
