From: H Hartley Sweeten <hartleys@visionengravers.com>
Subject: RE: [PATCH 11/36] net: ethernet: cirrus: remove unnecessary
 platform_set_drvdata()
Date: Mon, 13 May 2013 19:49:56 -0500
Message-ID: <ADE657CA350FB648AAC2C43247A983F0021D46AC8645@AUSP01VMBX24.collaborationhost.net>
References: <001b01ce4adb$1c5e04e0$551a0ea0$@samsung.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Jingoo Han <jg1.han@samsung.com>,
	"'David S. Miller'" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.bemta8.messagelabs.com ([216.82.243.202]:7585 "EHLO
	mail1.bemta8.messagelabs.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754656Ab3ENA52 convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 May 2013 20:57:28 -0400
In-Reply-To: <001b01ce4adb$1c5e04e0$551a0ea0$@samsung.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday, May 06, 2013 9:27 PM, Jingoo Han wrote:
> The driver core clears the driver data to NULL after device_release
> or on probe failure, since commit 0998d0631001288a5974afc0b2a5f568bcdecb4d
> (device-core: Ensure drvdata = NULL when no driver is bound).
> Thus, it is not needed to manually clear the device driver data to NULL.
>
> Signed-off-by: Jingoo Han <jg1.han@samsung.com>
> ---
>  drivers/net/ethernet/cirrus/ep93xx_eth.c |    1 -
>  1 files changed, 0 insertions(+), 1 deletions(-)

Reviewed-by: H Hartley Sweeten <hsweeten@visionengravers.com>
