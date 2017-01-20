From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: sctp: fix array overrun read on sctp_timer_tbl
Date: Fri, 20 Jan 2017 11:26:26 -0500 (EST)
Message-ID: <20170120.112626.159194842548687734.davem@davemloft.net>
References: <20170120130157.20034-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vyasevich@gmail.com, nhorman@tuxdriver.com,
        linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: colin.king@canonical.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170120130157.20034-1-colin.king@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin King <colin.king@canonical.com>
Date: Fri, 20 Jan 2017 13:01:57 +0000

> From: Colin Ian King <colin.king@canonical.com>
> 
> The comparison on the timeout can lead to an array overrun
> read on sctp_timer_tbl because of an off-by-one error. Fix
> this by using < instead of <= and also compare to the array
> size rather than SCTP_EVENT_TIMEOUT_MAX.
> 
> Fixes CoverityScan CID#1397639 ("Out-of-bounds read")
> 
> Signed-off-by: Colin Ian King <colin.king@canonical.com>

Applied.
