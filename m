From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] cxgb4vf: make a couple of functions static
Date: Wed, 04 Oct 2017 10:32:15 -0700 (PDT)
Message-ID: <20171004.103215.1424926789610505281.davem@davemloft.net>
References: <20171004132037.6409-1-colin.king@canonical.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: leedom@chelsio.com, netdev@vger.kernel.org,
        kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
To: colin.king@canonical.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171004132037.6409-1-colin.king@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Colin King <colin.king@canonical.com>
Date: Wed,  4 Oct 2017 14:20:37 +0100

> From: Colin Ian King <colin.king@canonical.com>
> 
> The functions t4vf_link_down_rc_str and t4vf_handle_get_port_info are
> local to the source and do not need to be in global scope, so make
> them static.
> 
> Cleans up sparse warnings:
> symbol 't4vf_link_down_rc_str' was not declared. Should it be static?
> symbol 't4vf_handle_get_port_info' was not declared. Should it be static?
> 
> Signed-off-by: Colin Ian King <colin.king@canonical.com>

Applied to net-next, thanks.
