From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 for v3.15] net: mvmdio: Check for a valid interrupt
 instead of an error
Date: Fri, 02 May 2014 16:19:25 -0400 (EDT)
Message-ID: <20140502.161925.32176445889713799.davem@davemloft.net>
References: <1398875331-18925-1-git-send-email-ezequiel.garcia@free-electrons.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, sebastian.hesselbarth@gmail.com,
	thomas.petazzoni@free-electrons.com,
	gregory.clement@free-electrons.com, tawfik@marvell.com,
	alior@marvell.com
To: ezequiel.garcia@free-electrons.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37118 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752218AbaEBUT0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 May 2014 16:19:26 -0400
In-Reply-To: <1398875331-18925-1-git-send-email-ezequiel.garcia@free-electrons.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
Date: Wed, 30 Apr 2014 13:28:51 -0300

> The following commit:
> 
> commit 9ec36cafe43bf835f8f29273597a5b0cbc8267ef
> Author: Rob Herring <robh@kernel.org>
> Date:   Wed Apr 23 17:57:41 2014 -0500
> 
>     of/irq: do irq resolution in platform_get_irq
> 
> changed platform_get_irq() which now returns EINVAL and EPROBE_DEFER,
> in addition to ENXIO. If there's no interrupt for mvmdio, platform_get_irq()
> returns EINVAL, but we currently check only for ENXIO.
> 
> Fix this by looking for a positive integer, which is the proper way of
> validating a virtual interrupt number.
> 
> While at it, add a proper handling for the deferral probe case.
> 
> Signed-off-by: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>

Applied, thanks.
