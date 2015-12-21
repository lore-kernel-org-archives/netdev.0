From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH net-next V2 1/4] net/mlx5e: Do not modify the TX SKB
Date: Mon, 21 Dec 2015 07:05:05 +0200
Message-ID: <CAJ3xEMiPYAFmKfF7_QJoOy++7y3FqNCWd7zzDz7xe5xdtvVXgQ@mail.gmail.com>
References: <1450647991-13736-1-git-send-email-saeedm@mellanox.com>
	<1450647991-13736-2-git-send-email-saeedm@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Richard Cochran <richardcochran@gmail.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Majd Dibbiny <majd@mellanox.com>,
	Saeed Mahameed <saeedm@dev.mellanox.co.il>
To: Saeed Mahameed <saeedm@mellanox.com>,
	Achiad Shochat <achiad@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f182.google.com ([209.85.213.182]:35197 "EHLO
	mail-ig0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750761AbbLUFFG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Dec 2015 00:05:06 -0500
Received: by mail-ig0-f182.google.com with SMTP id to4so29638638igc.0
        for <netdev@vger.kernel.org>; Sun, 20 Dec 2015 21:05:05 -0800 (PST)
In-Reply-To: <1450647991-13736-2-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Dec 20, 2015 at 11:46 PM, Saeed Mahameed wrote:
> From: Achiad Shochat <achiad@mellanox.com>
>
> If the SKB is cloned, or has an elevated users count, someone else
> can be looking at it at the same time.

>  drivers/net/ethernet/mellanox/mlx5/core/en.h      |    5 +-
>  drivers/net/ethernet/mellanox/mlx5/core/en_main.c |    5 +-
>  drivers/net/ethernet/mellanox/mlx5/core/en_tx.c   |   73 ++++++++++++---------
>  3 files changed, 49 insertions(+), 34 deletions(-)

Guys, can this can be made in a manner which is lighter w.r.t data
path changes? lets make sure we do things (1) right and (2) efficient

Or.
