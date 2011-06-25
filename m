From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [RFC 42/72] 82586.c/fec*: Move the Motorola drivers
Date: Sat, 25 Jun 2011 18:53:59 +0200
Message-ID: <201106251854.00096.arnd@arndb.de>
References: <1309010363-22750-1-git-send-email-jeffrey.t.kirsher@intel.com> <1309010363-22750-43-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Dan Malek <dmalek@jlc.net>, Sylvain Munaut <tnt@246tnt.com>,
	Richard Hirst <richard@sleepie.demon.co.uk>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.171]:60297 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751412Ab1FYQyJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Jun 2011 12:54:09 -0400
In-Reply-To: <1309010363-22750-43-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Saturday 25 June 2011, Jeff Kirsher wrote:
> Move the Motorola drivers into drivers/net/ethernet/motorola/ and
> make the necessary Kconfig and Makefile changes
> 
> CC: Dan Malek <dmalek@jlc.net>
> CC: Sylvain Munaut <tnt@246tNt.com>
> CC: Richard Hirst <richard@sleepie.demon.co.uk>
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> ---
>  drivers/net/Kconfig                                |   69 ---------------
>  drivers/net/Makefile                               |    9 --
>  drivers/net/ethernet/Kconfig                       |    1 +
>  drivers/net/ethernet/Makefile                      |    1 +
>  drivers/net/{ => ethernet/motorola}/82596.c        |    0
>  drivers/net/ethernet/motorola/Kconfig              |   88 ++++++++++++++++++++
>  drivers/net/ethernet/motorola/Makefile             |   13 +++
>  drivers/net/{ => ethernet/motorola}/fec.c          |    0
>  drivers/net/{ => ethernet/motorola}/fec.h          |    0
>  drivers/net/{ => ethernet/motorola}/fec_mpc52xx.c  |    0
>  drivers/net/{ => ethernet/motorola}/fec_mpc52xx.h  |    0
>  .../net/{ => ethernet/motorola}/fec_mpc52xx_phy.c  |    0
>  12 files changed, 103 insertions(+), 78 deletions(-)

The part of Motorola that made these originally is now known as
Freescale, so put these together with the other freescale parts.

	Arnd
