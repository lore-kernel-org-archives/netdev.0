From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: [PATCH 0/2] flexcan driver updates
Date: Tue, 26 Jun 2012 18:55:29 +0200
Message-ID: <4FE9E981.2080402@hartkopp.net>
References: <1340700563-8386-1-git-send-email-shawn.guo@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Marc Kleine-Budde <mkl@pengutronix.de>, netdev@vger.kernel.org,
	linux-arm-kernel@lists.infradead.org
To: Shawn Guo <shawn.guo@linaro.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.162]:48446 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758511Ab2FZQzg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Jun 2012 12:55:36 -0400
In-Reply-To: <1340700563-8386-1-git-send-email-shawn.guo@linaro.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 26.06.2012 10:49, Shawn Guo wrote:

> Here are a couple of flexcan driver/bindings updates, which are meant
> to get the driver more device tree friendly.
> 
> Shawn Guo (2):
>   net: flexcan: clock-frequency is optional for device tree probe
>   net: flexcan: add transceiver switch gpio support
> 
>  .../devicetree/bindings/net/can/fsl-flexcan.txt    |    6 ++++
>  drivers/net/can/flexcan.c                          |   30 ++++++++++++++++++++
>  2 files changed, 36 insertions(+), 0 deletions(-)
> 


Sorry Shawn, but your posting is pretty misplaced ...

Please check for the maintainers and mailing lists in the MAINTAINERS file
that match your suggested changes:

Documentation/devicetree/bindings/net/can/fsl-flexcan.txt =>

OPEN FIRMWARE AND FLATTENED DEVICE TREE
M:	Grant Likely <grant.likely@secretlab.ca>
M:	Rob Herring <rob.herring@calxeda.com>
L:	devicetree-discuss@lists.ozlabs.org (moderated for non-subscribers)
W:	http://fdt.secretlab.ca
T:	git git://git.secretlab.ca/git/linux-2.6.git
S:	Maintained
F:	Documentation/devicetree		<<<<<------------- !!!
F:	drivers/of
F:	include/linux/of*.h
K:	of_get_property
K:	of_match_table


drivers/net/can/flexcan.c =>

CAN NETWORK DRIVERS
M:	Wolfgang Grandegger <wg@grandegger.com>
M:	Marc Kleine-Budde <mkl@pengutronix.de>
L:	linux-can@vger.kernel.org
W:	http://gitorious.org/linux-can
T:	git git://gitorious.org/linux-can/linux-can-next.git
S:	Maintained
F:	drivers/net/can/			<<<<<------------- !!!
F:	include/linux/can/dev.h
F:	include/linux/can/error.h
F:	include/linux/can/netlink.h
F:	include/linux/can/platform/

So please post your suggested changes for the flexcan driver on the mailing
lists linux-can@vger.kernel.org and devicetree-discuss@lists.ozlabs.org

Once the changes are discussed and accepted they can be pulled by Dave Miller
from the CAN development git repository into the networking tree.

Thanks,
Oliver
