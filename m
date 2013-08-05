From: Chris Metcalf <cmetcalf@tilera.com>
Subject: Re: [PATCH -next] tile: fix missing unlock on error in tile_net_open()
Date: Mon, 5 Aug 2013 11:10:29 -0400
Message-ID: <51FFC065.3090108@tilera.com>
References: <CAPgLHd8k5yfO4G1Fvz86VSC-HbwgGEb8OwTShAa5e+owRvaMqg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <davem@davemloft.net>, <yongjun_wei@trendmicro.com.cn>,
	<netdev@vger.kernel.org>
To: Wei Yongjun <weiyj.lk@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from usmamail.tilera.com ([12.216.194.151]:50600 "EHLO
	USMAMAIL.TILERA.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752362Ab3HEPKc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 5 Aug 2013 11:10:32 -0400
In-Reply-To: <CAPgLHd8k5yfO4G1Fvz86VSC-HbwgGEb8OwTShAa5e+owRvaMqg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/5/2013 12:42 AM, Wei Yongjun wrote:
> From: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
>
> Add the missing unlock before return from function tile_net_open()
> in the error handling case.
>
> Introduced by commit f3286a3af89d6db7a488f3e8f02b98d67d50f00c.
> (tile: support multiple mPIPE shims in tilegx network driver)
>
> Signed-off-by: Wei Yongjun <yongjun_wei@trendmicro.com.cn>
> ---
>  drivers/net/ethernet/tile/tilegx.c | 4 +++-
>  1 file changed, 3 insertions(+), 1 deletion(-)

Thanks!

Acked-by: Chris Metcalf <cmetcalf@tilera.com>

-- 
Chris Metcalf, Tilera Corp.
http://www.tilera.com
