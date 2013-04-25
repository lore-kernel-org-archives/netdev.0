From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH net-next V3 3/5] net/mlx4_en: Add HW timestamping (TS)
 support
Date: Thu, 25 Apr 2013 21:26:27 +0200
Message-ID: <20130425192627.GA14429@netboy>
References: <1366733211-10228-1-git-send-email-amirv@mellanox.com>
 <1366733211-10228-4-git-send-email-amirv@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Eugenia Emantayev <eugenia@mellanox.com>
To: Amir Vadai <amirv@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f178.google.com ([209.85.215.178]:54949 "EHLO
	mail-ea0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758685Ab3DYT0j (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Apr 2013 15:26:39 -0400
Received: by mail-ea0-f178.google.com with SMTP id o10so1419251eaj.9
        for <netdev@vger.kernel.org>; Thu, 25 Apr 2013 12:26:38 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1366733211-10228-4-git-send-email-amirv@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 23, 2013 at 07:06:49PM +0300, Amir Vadai wrote:

> +u64 mlx4_en_get_cqe_ts(struct mlx4_cqe *cqe)
> +{
> +	u64 hi, lo;
> +	struct mlx4_ts_cqe *ts_cqe = (struct mlx4_ts_cqe *)cqe;
> +
> +	lo = (u64)be16_to_cpu(ts_cqe->timestamp_lo);
> +	hi = ((u64)be32_to_cpu(ts_cqe->timestamp_hi) + !lo) << 16;
                                                     ^^^^^
That looks a bit strange. Can you explain?

> +
> +	return hi | lo;
> +}

Thanks,
Richard
