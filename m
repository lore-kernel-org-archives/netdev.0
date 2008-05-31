From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 1/2] sfc: Use kernel I2C system and i2c-algo-bit driver
Date: Fri, 30 May 2008 22:19:59 -0400
Message-ID: <4840B5CF.2050901@pobox.com>
References: <cover.1212182201.git.bhutchings@solarflare.com> <20080530212703.GG1743@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-net-drivers@solarflare.com,
	Jean Delvare <khali@linux-fr.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:54294 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750801AbYEaCUB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 30 May 2008 22:20:01 -0400
In-Reply-To: <20080530212703.GG1743@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ben Hutchings wrote:
> Remove our own implementation of I2C bit-banging.
> 
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
> ---
>  drivers/net/sfc/Kconfig      |    2 +
>  drivers/net/sfc/Makefile     |    2 +-
>  drivers/net/sfc/boards.c     |    2 +-
>  drivers/net/sfc/boards.h     |    3 +-
>  drivers/net/sfc/efx.c        |    2 +
>  drivers/net/sfc/falcon.c     |   72 ++++++---
>  drivers/net/sfc/i2c-direct.c |  381 ------------------------------------------
>  drivers/net/sfc/i2c-direct.h |   91 ----------
>  drivers/net/sfc/net_driver.h |   11 +-
>  drivers/net/sfc/sfe4001.c    |  126 ++++++++-------
>  10 files changed, 133 insertions(+), 559 deletions(-)
>  delete mode 100644 drivers/net/sfc/i2c-direct.c
>  delete mode 100644 drivers/net/sfc/i2c-direct.h

applied 1-2


