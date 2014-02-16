From: Amir Vadai <amirv@mellanox.com>
Subject: Re: [PATCH net] net/mlx4_en: Fixed crash when port type is changed
Date: Sun, 16 Feb 2014 12:03:09 +0200
Message-ID: <20140216100307.GA3859@mtl-eit-vdi-22.mtl.labs.mlnx>
References: <1383815310-19116-1-git-send-email-amirv@mellanox.com>
 <20131107.191418.2145129150067281446.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, yevgenyp@mellanox.com,
	ogerlitz@mellanox.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f179.google.com ([209.85.215.179]:36707 "EHLO
	mail-ea0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750986AbaBPKDN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Feb 2014 05:03:13 -0500
Received: by mail-ea0-f179.google.com with SMTP id q10so6016670ead.38
        for <netdev@vger.kernel.org>; Sun, 16 Feb 2014 02:03:12 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <20131107.191418.2145129150067281446.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/11/13 19:14 -0500, David Miller wrote:
> From: Amir Vadai <amirv@mellanox.com>
> Date: Thu,  7 Nov 2013 11:08:30 +0200
> 
> > timecounter_init() was was called only after first potential
> > timecounter_read().
> > Moved mlx4_en_init_timestamp() before mlx4_en_init_netdev()
> > 
> > Signed-off-by: Amir Vadai <amirv@mellanox.com>
> > ---
> > Please pull into -stable for kernels >= 3.10
> 
> Applied and queued up for -stable, thanks.

Hi,

I see that this patch [1] was applied to 3.10.y and 3.12.y.
But somehow it was dropped from 3.11.y
Please pull it there too.

Thanks,
Amir

[1] - 1ec4864 net/mlx4_en: Fixed crash when port type is changed
