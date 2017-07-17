From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][next] net: bcmgenet: return NULL rather than 0 for
 null pointer
Date: Mon, 17 Jul 2017 08:55:56 -0700 (PDT)
Message-ID: <20170717.085556.1127444301775237113.davem@davemloft.net>
References: <20170717090725.32540-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: f.fainelli@gmail.com, netdev@vger.kernel.org,
        kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: colin.king@canonical.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170717090725.32540-1-colin.king@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin King <colin.king@canonical.com>
Date: Mon, 17 Jul 2017 10:07:25 +0100

> From: Colin Ian King <colin.king@canonical.com>
> 
> Don't return plain integer 0, instead return NULL
> 
> Fixes sparse warning:
> warning: Using plain integer as NULL pointer
> 
> Signed-off-by: Colin Ian King <colin.king@canonical.com>

This does not apply cleanly to the net-next tree.
