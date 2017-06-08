From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] net: ethernet: ti: cpsw: enable
 HWTSTAMP_FILTER_PTP_V1_L4_EVENT filter
Date: Thu, 08 Jun 2017 19:32:16 -0400 (EDT)
Message-ID: <20170608.193216.1564917208894051322.davem@davemloft.net>
References: <20170608185131.32653-1-grygorii.strashko@ti.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nsekhar@ti.com,
        linux-kernel@vger.kernel.org, linux-omap@vger.kernel.org
To: grygorii.strashko@ti.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170608185131.32653-1-grygorii.strashko@ti.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Grygorii Strashko <grygorii.strashko@ti.com>
Date: Thu, 8 Jun 2017 13:51:31 -0500

> CPSW driver supports PTP v1 messages, but for unknown reasons this filter
> is not advertised. As result,
> ./tools/testing/selftests/networking/timestamping/timestamping utility
> can't be used for testing of CPSW RX timestamping with option
> SOF_TIMESTAMPING_RX_HARDWARE, because it uses
> HWTSTAMP_FILTER_PTP_V1_L4_SYNC filter.
> 
> Hence, fix it by advertising HWTSTAMP_FILTER_PTP_V1_L4_XXX filters
> in CPSW driver.
> 
> Signed-off-by: Grygorii Strashko <grygorii.strashko@ti.com>

Applied.
