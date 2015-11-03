From: Or Gerlitz <gerlitz.or@gmail.com>
Subject: Re: [PATCH net-next V1 0/7] Mellanox mlx5e driver update, Nov 3 2015
Date: Tue, 3 Nov 2015 08:15:31 +0200
Message-ID: <CAJ3xEMi75E2=Bf-coQAeybu=aE+-FfFVkEnkg+DqFioqYQhp+g@mail.gmail.com>
References: <1446530844-14077-1-git-send-email-ogerlitz@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f179.google.com ([209.85.213.179]:34147 "EHLO
	mail-ig0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752067AbbKCGPc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Nov 2015 01:15:32 -0500
Received: by igpw7 with SMTP id w7so62832597igp.1
        for <netdev@vger.kernel.org>; Mon, 02 Nov 2015 22:15:31 -0800 (PST)
In-Reply-To: <1446530844-14077-1-git-send-email-ogerlitz@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 3, 2015 at 8:07 AM, Or Gerlitz <ogerlitz@mellanox.com> wrote:
> This series contains bunch of small fixes to the mlx5e driver from Achiad.

Oops, I missed your email from 2h ago... but these all ARE bug fixes,
so hopefully
I didn't really violated the directive (I guess I should have just
asked, but again,
I missed the email...)

Or.

> Applies on net-next commit e7b63ff "Merge branch 'master' of
> git://git.kernel.org/pub/scm/linux/kernel/git/klassert/ipsec-next"

> Changes from V0:
>   - removed the driver patch that dealt with IRQ affinity changes during
>     NAPI poll, as this is a generic problem which needs generic solution.
>
> Achiad Shochat (7):
>   net/mlx5e: Avoid NULL pointer access in case of configuration failure
>   net/mlx5e: Wait for RX buffers initialization in a more proper manner
>   net/mlx5_core: Use the the real irqn in eq->irqn
>   net/mlx5e: Don't allow more than max supported channels
>   net/mlx5e: Return error in case mlx5e_set_features() fails
>   net/mlx5e: Re-eanble client vlan TX acceleration
>   net/mlx5e: Fix LSO vlan insertion
>
>  drivers/net/ethernet/mellanox/mlx5/core/en.h       |  6 +++++
>  .../net/ethernet/mellanox/mlx5/core/en_ethtool.c   |  5 ++---
>  drivers/net/ethernet/mellanox/mlx5/core/en_main.c  | 16 ++++++++-----
>  drivers/net/ethernet/mellanox/mlx5/core/en_tx.c    | 26 +++++++++++++++++++---
>  drivers/net/ethernet/mellanox/mlx5/core/eq.c       |  8 +++----
>  5 files changed, 46 insertions(+), 15 deletions(-)
