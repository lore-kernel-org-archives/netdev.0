From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH net-next 7/8] ethtool: Replace ethtool_ops::{get,set}_rxfh_indir()
 with {get,set}_rxfh()
Date: Sun, 1 Jun 2014 20:09:37 -0700
Message-ID: <CAL3LdT7HYkHjqP9Y9dOf0x-E9wgWfEzJ8nY61x_GRsjfXDdL1A@mail.gmail.com>
References: <1401670659.14007.94.camel@deadeye.wl.decadent.org.uk>
	<1401671016.14007.101.camel@deadeye.wl.decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Venkat Duvvuru <VenkatKumar.Duvvuru@emulex.com>
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f45.google.com ([209.85.219.45]:44399 "EHLO
	mail-oa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753171AbaFBDJh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Jun 2014 23:09:37 -0400
Received: by mail-oa0-f45.google.com with SMTP id l6so4066163oag.4
        for <netdev@vger.kernel.org>; Sun, 01 Jun 2014 20:09:37 -0700 (PDT)
In-Reply-To: <1401671016.14007.101.camel@deadeye.wl.decadent.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jun 1, 2014 at 6:03 PM, Ben Hutchings <ben@decadent.org.uk> wrote:
> ETHTOOL_{G,S}RXFHINDIR and ETHTOOL_{G,S}RSSH should work for drivers
> regardless of whether they expose the hash key, unless you try to
> set a hash key for a driver that doesn't expose it.
>
> Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
> ---
>  drivers/net/ethernet/broadcom/bnx2x/bnx2x_ethtool.c | 15 ++++++++-------
>  drivers/net/ethernet/broadcom/tg3.c                 |  8 ++++----
>  drivers/net/ethernet/chelsio/cxgb4/cxgb4_main.c     |  8 ++++----
>  drivers/net/ethernet/intel/i40evf/i40evf_ethtool.c  | 15 +++++++++------
>  drivers/net/ethernet/intel/igb/igb_ethtool.c        |  9 +++++----
>  drivers/net/ethernet/mellanox/mlx4/en_ethtool.c     | 10 +++++-----
>  drivers/net/ethernet/sfc/ethtool.c                  | 10 +++++-----
>  include/linux/ethtool.h                             |  6 ------
>  net/core/ethtool.c                                  |  8 ++++----
>  9 files changed, 44 insertions(+), 45 deletions(-)
>

For the Intel driver changes...
Acked-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
