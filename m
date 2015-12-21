From: Richard Cochran <richardcochran@gmail.com>
Subject: Re: [PATCH net-next V2 4/4] net/mlx5e: Add PTP Hardware Clock (PHC)
 support
Date: Mon, 21 Dec 2015 10:16:46 +0100
Message-ID: <20151221091646.GB2297@localhost.localdomain>
References: <1450647991-13736-1-git-send-email-saeedm@mellanox.com>
 <1450647991-13736-5-git-send-email-saeedm@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>,
	Tal Alon <talal@mellanox.com>,
	Majd Dibbiny <majd@mellanox.com>,
	Achiad Shochat <achiad@mellanox.com>, saeedm@dev.mellanox.co.il
To: Saeed Mahameed <saeedm@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f41.google.com ([74.125.82.41]:36555 "EHLO
	mail-wm0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751006AbbLUJQv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Dec 2015 04:16:51 -0500
Received: by mail-wm0-f41.google.com with SMTP id p187so59668889wmp.1
        for <netdev@vger.kernel.org>; Mon, 21 Dec 2015 01:16:50 -0800 (PST)
Content-Disposition: inline
In-Reply-To: <1450647991-13736-5-git-send-email-saeedm@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Dec 20, 2015 at 11:46:31PM +0200, Saeed Mahameed wrote:
> From: Eran Ben Elisha <eranbe@mellanox.com>
> 
> Add a PHC support to the mlx5_en driver. Use reader/writer spinlocks to
> protect the timecounter since every packet received needs to call
> timecounter_cycle2time() when timestamping is enabled.  This can become
> a performance bottleneck with RSS and multiple receive queues if normal
> spinlocks are used.
> 
> The driver has been tested with both Documentation/ptp/testptp and the
> linuxptp project (http://linuxptp.sourceforge.net/) on a Mellanox
> ConnectX-4 card.
> 
> Signed-off-by: Eran Ben Elisha <eranbe@mellanox.com>
> Cc: Richard Cochran <richardcochran@gmail.com>
> Signed-off-by: Saeed Mahameed <saeedm@mellanox.com>

Acked-by: Richard Cochran <richardcochran@gmail.com>
