From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH net-next v4 1/2] mlx4_en: Add PTP hardware clock
Date: Wed, 1 Jan 2014 10:46:45 +0100
Message-ID: <20140101094644.GA7682@netboy>
References: <1388511580-3657-1-git-send-email-shawn.bohrer@gmail.com>
 <1388511580-3657-2-git-send-email-shawn.bohrer@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Amir Vadai <amirv@mellanox.com>, netdev@vger.kernel.org,
	tomk@rgmadvisors.com, Hadar Hen Zion <hadarh@mellanox.com>,
	Shawn Bohrer <sbohrer@rgmadvisors.com>
To: Shawn Bohrer <shawn.bohrer@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f179.google.com ([209.85.215.179]:57332 "EHLO
	mail-ea0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752800AbaAAJq4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Jan 2014 04:46:56 -0500
Received: by mail-ea0-f179.google.com with SMTP id r15so5890625ead.10
        for <netdev@vger.kernel.org>; Wed, 01 Jan 2014 01:46:54 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1388511580-3657-2-git-send-email-shawn.bohrer@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 31, 2013 at 11:39:39AM -0600, Shawn Bohrer wrote:
> From: Shawn Bohrer <sbohrer@rgmadvisors.com>
> 
> This adds a PHC to the mlx4_en driver. We use reader/writer spinlocks to
> protect the timecounter since every packet received needs to call
> timecounter_cycle2time() when timestamping is enabled.  This can become
> a performance bottleneck with RSS and multiple receive queues if normal
> spinlocks are used.
> 
> This driver has been tested with both Documentation/ptp/testptp and the
> linuxptp project (http://linuxptp.sourceforge.net/) on a Mellanox
> ConnectX-3 card.
> 
> Signed-off-by: Shawn Bohrer <sbohrer@rgmadvisors.com>
> ---
>  drivers/net/ethernet/mellanox/mlx4/en_clock.c   |  194 ++++++++++++++++++++++-
>  drivers/net/ethernet/mellanox/mlx4/en_ethtool.c |    3 +
>  drivers/net/ethernet/mellanox/mlx4/en_main.c    |    3 +
>  drivers/net/ethernet/mellanox/mlx4/mlx4_en.h    |    6 +
>  4 files changed, 198 insertions(+), 8 deletions(-)

Acked-by: Richard Cochran <richardcochran@gmail.com>
