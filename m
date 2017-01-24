From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][V3][net-next] net: sctp: fix array overrun read on
 sctp_timer_tbl
Date: Tue, 24 Jan 2017 15:24:49 -0500 (EST)
Message-ID: <20170124.152449.1095694033734759610.davem@davemloft.net>
References: <20170124092554.27019-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: vyasevich@gmail.com, nhorman@tuxdriver.com,
        linux-sctp@vger.kernel.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: colin.king@canonical.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170124092554.27019-1-colin.king@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin King <colin.king@canonical.com>
Date: Tue, 24 Jan 2017 09:25:54 +0000

> From: Colin Ian King <colin.king@canonical.com>
> 
> Table sctp_timer_tbl is missing a TIMEOUT_RECONF string so
> add this in. Also compare timeout with the size of the array
> sctp_timer_tbl rather than SCTP_EVENT_TIMEOUT_MAX.  Also add
> a build time check that SCTP_EVENT_TIMEOUT_MAX is correct
> so we don't ever get this kind of mismatch between the table
> and SCTP_EVENT_TIMEOUT_MAX in the future.
> 
> Kudos to Marcelo Ricardo Leitner for spotting the missing string
> and suggesting the build time sanity check.
> 
> Fixes CoverityScan CID#1397639 ("Out-of-bounds read")
> 
> Fixes: 7b9438de0cd4 ("sctp: add stream reconf timer")
> Signed-off-by: Colin Ian King <colin.king@canonical.com>

Applied.
