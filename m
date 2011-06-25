From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: [RFC 11/72] cassini/niu/sun*: Move the Sun drivers
Date: Sat, 25 Jun 2011 16:46:43 +0200
Message-ID: <4E05F4D3.9020407@hartkopp.net>
References: <1309010363-22750-1-git-send-email-jeffrey.t.kirsher@intel.com> <1309010363-22750-12-git-send-email-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Sam Creasey <sammy@sammy.net>,
	Adrian Sun <asun@darksunrising.com>,
	Benjamin Herrenscmidt <benh@kernel.crashing.org>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mo-p00-ob.rzone.de ([81.169.146.161]:42657 "EHLO
	mo-p00-ob.rzone.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751452Ab1FYOuj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Jun 2011 10:50:39 -0400
In-Reply-To: <1309010363-22750-12-git-send-email-jeffrey.t.kirsher@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 25.06.2011 15:58, Jeff Kirsher wrote:
> Moves the Sun drivers into drivers/net/ethernet/sun/ and make
> the necessary Kconfig and Makefile changes.
> 

(..)

> ---
>  MAINTAINERS                                 |    1 +
>  drivers/net/Kconfig                         |   75 ----------------------
>  drivers/net/Makefile                        |   11 +---
>  drivers/net/ethernet/Kconfig                |    1 +
>  drivers/net/ethernet/Makefile               |    1 +
>  drivers/net/ethernet/sun/Kconfig            |   91 +++++++++++++++++++++++++++
>  drivers/net/ethernet/sun/Makefile           |   12 ++++
>  drivers/net/{ => ethernet/sun}/cassini.c    |    0
>  drivers/net/{ => ethernet/sun}/cassini.h    |    0
>  drivers/net/{ => ethernet/sun}/niu.c        |    0
>  drivers/net/{ => ethernet/sun}/niu.h        |    0
>  drivers/net/{ => ethernet/sun}/sun3_82586.c |    0
>  drivers/net/{ => ethernet/sun}/sun3_82586.h |    0

s/sun3_// in filenames?

>  drivers/net/{ => ethernet/sun}/sunbmac.c    |    0
>  drivers/net/{ => ethernet/sun}/sunbmac.h    |    0
>  drivers/net/{ => ethernet/sun}/sungem.c     |    0
>  drivers/net/{ => ethernet/sun}/sungem.h     |    0
>  drivers/net/{ => ethernet/sun}/sungem_phy.c |    0
>  drivers/net/{ => ethernet/sun}/sungem_phy.h |    0
>  drivers/net/{ => ethernet/sun}/sunhme.c     |    0
>  drivers/net/{ => ethernet/sun}/sunhme.h     |    0
>  drivers/net/{ => ethernet/sun}/sunqe.c      |    0
>  drivers/net/{ => ethernet/sun}/sunqe.h      |    0
>  drivers/net/{ => ethernet/sun}/sunvnet.c    |    0
>  drivers/net/{ => ethernet/sun}/sunvnet.h    |    0

s/sun// in filenames?

Regards,
Oliver
