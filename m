From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH v2.6.26] Add support for board-level PHY fixups
Date: Fri, 25 Apr 2008 02:02:53 -0400
Message-ID: <4811740D.4060707@pobox.com>
References: <1208557794-5940-1-git-send-email-afleming@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Andy Fleming <afleming@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:58516 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1758671AbYDYGC4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 Apr 2008 02:02:56 -0400
In-Reply-To: <1208557794-5940-1-git-send-email-afleming@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andy Fleming wrote:
> Sometimes the specific interaction between the platform and the PHY requires
> special handling.  For instance, to change where the PHY's clock input is, or to
> add a delay to account for latency issues in the data path.  We add a mechanism
> for registering a callback with the PHY Lib to be called on matching PHYs when
> they are brought up, or reset.
> 
> Signed-off-by: Andy Fleming <afleming@freescale.com>
> ---
>  Documentation/networking/phy.txt |   38 +++++++++++-
>  drivers/net/phy/mdio_bus.c       |    3 +
>  drivers/net/phy/phy.c            |    4 +-
>  drivers/net/phy/phy_device.c     |  129 ++++++++++++++++++++++++++++++++++----
>  include/linux/phy.h              |   24 +++++++-
>  5 files changed, 182 insertions(+), 16 deletions(-)

applied, though I wish the kernel would unify on the choice of "fixup" 
or "quirk"


