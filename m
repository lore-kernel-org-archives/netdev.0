From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH] smc91x: disable DMA mode on the logicpd pxa270
Date: Mon, 26 Jun 2006 22:02:52 -0400
Message-ID: <44A091CC.90607@pobox.com>
References: <20060623212436.GB4843@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nico@cam.org, mikee@logicpd.com,
	peterb@logicpd.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:18133 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S932946AbWF0CC5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Jun 2006 22:02:57 -0400
To: Lennert Buytenhek <buytenh@wantstofly.org>
In-Reply-To: <20060623212436.GB4843@xi.wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Lennert Buytenhek wrote:
> Enabling PXA DMA for the smc91x on the logicpd pxa270 produces
> unacceptable interference with the TFT panel, so disable it.  Also
> delete the lpd270 versions of the SMC_{in,out}[bl]() macros, as they
> aren't used, since the board only supports 16bit accesses.
> 
> Signed-off-by: Lennert Buytenhek <buytenh@wantstofly.org>
> 
> Index: linux-2.6.17-git5/drivers/net/smc91x.h

ACK, but git-applymbox claims the patch is corrupt


