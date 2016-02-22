From: Rob Herring <robh@kernel.org>
Subject: Re: [PATCH can-next 2/2] CAN: rcar: add device tree support for
 r8a779[234]
Date: Sun, 21 Feb 2016 21:36:44 -0600
Message-ID: <20160222033644.GB24277@rob-hp-laptop>
References: <1456107350-12100-1-git-send-email-horms+renesas@verge.net.au>
 <1456107350-12100-3-git-send-email-horms+renesas@verge.net.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Wolfgang Grandegger <wg@grandegger.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>,
	Magnus Damm <magnus.damm@gmail.com>, linux-can@vger.kernel.org,
	netdev@vger.kernel.org, linux-renesas-soc@vger.kernel.org,
	devicetree@vger.kernel.org
To: Simon Horman <horms+renesas@verge.net.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:46215 "EHLO mail.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752526AbcBVDgu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 21 Feb 2016 22:36:50 -0500
Content-Disposition: inline
In-Reply-To: <1456107350-12100-3-git-send-email-horms+renesas@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 22, 2016 at 11:15:50AM +0900, Simon Horman wrote:
> Simply document new compatibility string.
> As a previous patch adds a generic R-Car Gen2 compatibility string
> there appears to be no need for a driver updates.
> 
> By documenting this compat sting it may be used in DTSs shipped, for
> example as part of ROMs. It must be used in conjunction with the Gen2
> fallback compat string. At this time there are no known differences between
> the r8a779[234] IP blocks and that implemented by the driver for the Gen2
> fallback compat string. Thus there is no need to update the driver as the
> use of the Gen2 fallback compat string will activate the correct code in
> the current driver while leaving the option for r8a779[234]-specific driver
> code to be activated in an updated driver should the need arise.
> 
> Signed-off-by: Simon Horman <horms+renesas@verge.net.au>
> ---
>  Documentation/devicetree/bindings/net/can/rcar_can.txt | 3 +++
>  drivers/net/can/rcar_can.c                             | 3 +++
>  2 files changed, 6 insertions(+)

Acked-by: Rob Herring <robh@kernel.org>
