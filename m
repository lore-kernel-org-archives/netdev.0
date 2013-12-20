From: Chris Metcalf <cmetcalf@tilera.com>
Subject: Re: [PATCH] tile_net: Always enable PTP clock support on TILE-Gx
Date: Fri, 20 Dec 2013 09:40:19 -0500
Message-ID: <52B456D3.9000106@tilera.com>
References: <1387480874.1876.33.camel@bwh-desktop.uk.level5networks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Richard Cochran <richardcochran@gmail.com>,
	netdev <netdev@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from usmamail.tilera.com ([12.216.194.151]:23314 "EHLO
	USMAMAIL.TILERA.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752840Ab3LTOkV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Dec 2013 09:40:21 -0500
In-Reply-To: <1387480874.1876.33.camel@bwh-desktop.uk.level5networks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/19/2013 2:21 PM, Ben Hutchings wrote:
> All other net drivers with PTP support enable it unconditionally.
> Make tile_net consistent with this.
>
> Signed-off-by: Ben Hutchings <bhutchings@solarflare.com>
> ---
> Totally untested as I don't have even a compiler for this.
>
> Ben.
>
>  drivers/net/ethernet/tile/Kconfig  | 12 +-----------
>  drivers/net/ethernet/tile/tilegx.c | 24 ------------------------
>  2 files changed, 1 insertion(+), 35 deletions(-)

Acked-by: Chris Metcalf <cmetcalf@tilera.com>

-- 
Chris Metcalf, Tilera Corp.
http://www.tilera.com
