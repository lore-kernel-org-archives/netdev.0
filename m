From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH net-next 8/8] net/mlx4_en: Extend checksum offloading by
 CHECKSUM COMPLETE
Date: Fri, 31 Oct 2014 01:28:49 +0200
Message-ID: <CAJ3xEMgC75anCmeKie8NZBZHfR8OW67pBiPQhyLUPK9cNJZHMg@mail.gmail.com>
References: <1414685216-28907-1-git-send-email-ogerlitz@mellanox.com>
	<1414685216-28907-9-git-send-email-ogerlitz@mellanox.com>
	<CAPshTChwewGiP712ki-BGu6VWhZTVOfZDzFm8NEqvon7uLhEWA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Or Gerlitz <ogerlitz@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Matan Barak <matanb@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Shani Michaeli <shanim@mellanox.com>
To: Jerry Chu <hkchu@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f51.google.com ([209.85.218.51]:53077 "EHLO
	mail-oi0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1161292AbaJ3X2t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Oct 2014 19:28:49 -0400
Received: by mail-oi0-f51.google.com with SMTP id g201so4880345oib.10
        for <netdev@vger.kernel.org>; Thu, 30 Oct 2014 16:28:49 -0700 (PDT)
In-Reply-To: <CAPshTChwewGiP712ki-BGu6VWhZTVOfZDzFm8NEqvon7uLhEWA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 30, 2014 at 11:20 PM, Jerry Chu <hkchu@google.com> wrote:
> Acked-by: H.K. Jerry Chu <hkchu@google.com>
>
> BTW, will the patch work for all versions of the chip?

If you'll look carefully, you'll see we go that path only when
priv->flags & MLX4_EN_FLAG_RX_CSUM_NON_TCP_UDP is true. This currently
holds only for ConnectX3 and not ConnectX3-pro. Down the road, the
feature will also be available for the -pro too.
