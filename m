From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: cdg: make struct tcp_cdg static
Date: Mon, 16 Oct 2017 21:25:00 +0100 (WEST)
Message-ID: <20171016.212500.1664833771375901207.davem@davemloft.net>
References: <20171016133321.15477-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, yoshfuji@linux-ipv6.org,
        netdev@vger.kernel.org, kernel-janitors@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: colin.king@canonical.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171016133321.15477-1-colin.king@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin King <colin.king@canonical.com>
Date: Mon, 16 Oct 2017 14:33:21 +0100

> From: Colin Ian King <colin.king@canonical.com>
> 
> The structure tcp_cdg is local to the source and
> does not need to be in global scope, so make it static.
> 
> Cleans up sparse warning:
> symbol 'tcp_cdg' was not declared. Should it be static?
> 
> Signed-off-by: Colin Ian King <colin.king@canonical.com>

Applied.
