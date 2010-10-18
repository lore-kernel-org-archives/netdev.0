From: Marc Zyngier <maz@misterjones.org>
Subject: Re: [PATCH 6/8] can: mcp251x: Don't use pdata->model for chip selection
 anymore
Date: Mon, 18 Oct 2010 15:49:11 +0200
Message-ID: <d4c9d3f3d2843bd9cdb4cbb6a75236ce@localhost>
References: <1287408674-15412-1-git-send-email-mkl@pengutronix.de> <1287408674-15412-7-git-send-email-mkl@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: <socketcan-core@lists.berlios.de>, <netdev@vger.kernel.org>,
	Christian Pellegrin <chripell@fsfe.org>
To: Marc Kleine-Budde <mkl@pengutronix.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from inca-roads.misterjones.org ([213.251.177.50]:41110 "EHLO
	inca-roads.misterjones.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755982Ab0JROMF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Oct 2010 10:12:05 -0400
In-Reply-To: <1287408674-15412-7-git-send-email-mkl@pengutronix.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Mon, 18 Oct 2010 15:31:12 +0200, Marc Kleine-Budde <mkl@pengutronix.de>
wrote:
> Since commit e446630c960946b5c1762e4eadb618becef599e7, i.e. v2.6.35-rc1,
> the mcp251x chip model can be selected via the modalias member in the
> struct spi_board_info. The driver stores the actual model in the
> struct mcp251x_platform_data.
> 
> From the driver point of view the platform_data should be read only.
> Since all in-tree users of the mcp251x have already been converted to
> the modalias method, this patch moves the "model" member from the
> struct mcp251x_platform_data to the driver's private data structure.
> 
> Signed-off-by: Marc Kleine-Budde <mkl@pengutronix.de>
> Cc: Christian Pellegrin <chripell@fsfe.org>
> Cc: Marc Zyngier <maz@misterjones.org>

Acked-by: Marc Zyngier <maz@misterjones.org>
-- 
Who you jivin' with that Cosmik Debris?
