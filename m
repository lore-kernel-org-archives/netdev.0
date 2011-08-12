From: H Hartley Sweeten <hartleys@visionengravers.com>
Subject: RE: [net-next 02/10] cirrus: Move the Cirrus network driver
Date: Fri, 12 Aug 2011 12:29:00 -0500
Message-ID: <ADE657CA350FB648AAC2C43247A983F001F388389C76@AUSP01VMBX24.collaborationhost.net>
References: <1313146371-6562-1-git-send-email-jeffrey.t.kirsher@intel.com>
 <1313146371-6562-3-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"gospo@redhat.com" <gospo@redhat.com>,
	"sassmann@redhat.com" <sassmann@redhat.com>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	"davem@davemloft.net" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail209.messagelabs.com ([216.82.255.3]:42669 "EHLO
	mail209.messagelabs.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751939Ab1HLR3F convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Aug 2011 13:29:05 -0400
In-Reply-To: <1313146371-6562-3-git-send-email-jeffrey.t.kirsher@intel.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Friday, August 12, 2011 3:53 AM, Jeff Kirsher wrote:
>
> Move the Cirrus Ethernet driver into drivers/net/ethernet/cirrus/
> and make the necessary Kconfig and Makefile changes
>
> CC: Hartley Sweeten <hsweeten@visionengravers.com>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
>  MAINTAINERS                                       |    2 +-
>  drivers/net/arm/Kconfig                           |    8 ------
>  drivers/net/arm/Makefile                          |    1 -
>  drivers/net/ethernet/Kconfig                      |    1 +
>  drivers/net/ethernet/Makefile                     |    1 +
>  drivers/net/ethernet/cirrus/Kconfig               |   28 +++++++++++++++++++++
>  drivers/net/ethernet/cirrus/Makefile              |    5 +++
>  drivers/net/{arm => ethernet/cirrus}/ep93xx_eth.c |    0
>  8 files changed, 36 insertions(+), 10 deletions(-)
>  create mode 100644 drivers/net/ethernet/cirrus/Kconfig
>  create mode 100644 drivers/net/ethernet/cirrus/Makefile
>  rename drivers/net/{arm => ethernet/cirrus}/ep93xx_eth.c (100%)

Acked-by: H Hartley Sweeten <hsweeten@visionengravers.com>

Will the Kconfig change require an update to ep93xx_defconfig in order to
have CONFIG_EP93XX_ETH selected?

Currently it has these relevant selections:

CONFIG_NET=y
CONFIG_NETDEVICES=y
CONFIG_NET_ETHERNET=y
CONFIG_EP93XX_ETH=y

Will CONFIG_NET_VENDOR_CIRRUS need to be added or will kconfig figure out
the dependency automatically?

Regards,
Hartley
