From: Rob Herring <robh@kernel.org>
Subject: Re: [PATCH v3 net-next 2/2] net: ethernet: enc28j60: add device tree
 support
Date: Tue, 3 May 2016 11:51:36 -0500
Message-ID: <20160503165136.GA24880@rob-hp-laptop>
References: <1461873975-6368-1-git-send-email-mhei@heimpold.de>
 <1461873975-6368-3-git-send-email-mhei@heimpold.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jonathan Cameron <jic23@kernel.org>,
	"Andrew F . Davis" <afd@ti.com>, Mark Brown <broonie@kernel.org>,
	netdev@vger.kernel.org, devicetree@vger.kernel.org,
	Pawel Moll <pawel.moll@arm.com>,
	Mark Rutland <mark.rutland@arm.com>,
	Ian Campbell <ijc+devicetree@hellion.org.uk>,
	Kumar Gala <galak@codeaurora.org>
To: Michael Heimpold <mhei@heimpold.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:41897 "EHLO mail.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756224AbcECQvn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 May 2016 12:51:43 -0400
Content-Disposition: inline
In-Reply-To: <1461873975-6368-3-git-send-email-mhei@heimpold.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 28, 2016 at 10:06:15PM +0200, Michael Heimpold wrote:
> The following patch adds the required match table for device tree support
> (and while at, fix the indent). It's also possible to specify the
> MAC address in the DT blob.
> 
> Also add the corresponding binding documentation file.
> 
> Signed-off-by: Michael Heimpold <mhei@heimpold.de>
> ---
> 
> Changelog:
> 
> v3: * renamed and improved binding documentation as
>       suggested by Rob Herring
> 
> v2: * took care of Arnd Bergmann's review comments
>       - allow to specify MAC address via DT
>       - unconditionally define DT id table
>     * increased the driver version minor number
>     * driver author's email address bounces, removed from address list
> 
> v1: * Initial submission
> 
> 
>  .../devicetree/bindings/net/microchip,enc28j60.txt | 59 ++++++++++++++++++++++

Acked-by: Rob Herring <robh@kernel.org>

>  drivers/net/ethernet/microchip/enc28j60.c          | 20 ++++++--
>  2 files changed, 76 insertions(+), 3 deletions(-)
>  create mode 100644 Documentation/devicetree/bindings/net/microchip,enc28j60.txt
