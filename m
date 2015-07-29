From: Scott Wood <scottwood@freescale.com>
Subject: Re: [PATCH net-next v2] gianfar: Fix warnings when built on 64-bit
Date: Wed, 29 Jul 2015 11:06:01 -0500
Message-ID: <1438185961.2993.335.camel@freescale.com>
References: <1438175586-11614-1-git-send-email-claudiu.manoil@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, "David S. Miller" <davem@davemloft.net>,
	<arnd@arndb.de>
To: Claudiu Manoil <claudiu.manoil@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bl2on0121.outbound.protection.outlook.com ([65.55.169.121]:24800
	"EHLO na01-bl2-obe.outbound.protection.outlook.com"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750839AbbG2QGK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Jul 2015 12:06:10 -0400
In-Reply-To: <1438175586-11614-1-git-send-email-claudiu.manoil@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-07-29 at 16:13 +0300, Claudiu Manoil wrote:
> From: Scott Wood <scottwood@freescale.com>
> 
> As part of defconfig consolidation using fragments, we'd like to be
> able to have the same drivers enabled on 32-bit and 64-bit.  Gianfar
> happens to only exist on 32-bit systems, and when building the
> resulting 64-bit kernel warnings were produced.
> 
> A couple of the warnings are trivial, but the rfbptr code has deeper
> issues.  It uses the virtual address as the DMA address, which again,
> happens to work in the environments where this driver is currently
> used, but is not the right thing to do.
> 
> Fixes: 45b679c9a3cc ("gianfar: Implement PAUSE frame generation
> support")
> Signed-off-by: Scott Wood <scottwood@freescale.com>
> Signed-off-by: Claudiu Manoil <claudiu.manoil@freescale.com>
> 
> ---
> v2 - rebased/reworked on top of net-next (instead of net);
>    - removed CONFIG_PM unrelated change;

Are you going to submit the CONFIG_PM change separately?  It fixes a warning 
when CONFIG_PM is not enabled.

-Scott
