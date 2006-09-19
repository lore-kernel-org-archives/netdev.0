From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH 08/23] e1000: add multicast stats counters
Date: Tue, 19 Sep 2006 15:28:18 -0400
Message-ID: <451044D2.3000509@pobox.com>
References: <20060919172623.4605.56860.stgit@gitlost.site> <20060919172850.4605.81213.stgit@gitlost.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	"Kok, Auke" <auke@foo-projects.org>,
	"Ronciak, John" <john.ronciak@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:37563 "EHLO mail.dvmed.net")
	by vger.kernel.org with ESMTP id S1751042AbWIST2V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Sep 2006 15:28:21 -0400
To: "Kok, Auke" <auke-jan.h.kok@intel.com>
In-Reply-To: <20060919172850.4605.81213.stgit@gitlost.site>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Kok, Auke wrote:
> Signed-off-by: Mitch Williams <mitch.a.williams@intel.com>
> Signed-off-by: Auke Kok <auke-jan.h.kok@intel.com>
> ---
> 
>  drivers/net/e1000/e1000_ethtool.c |    4 ++++
>  1 files changed, 4 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/net/e1000/e1000_ethtool.c b/drivers/net/e1000/e1000_ethtool.c
> index a954746..0d329d6 100644
> --- a/drivers/net/e1000/e1000_ethtool.c
> +++ b/drivers/net/e1000/e1000_ethtool.c
> @@ -60,6 +60,10 @@ static const struct e1000_stats e1000_gs
>  	{ "tx_packets", E1000_STAT(net_stats.tx_packets) },
>  	{ "rx_bytes", E1000_STAT(net_stats.rx_bytes) },
>  	{ "tx_bytes", E1000_STAT(net_stats.tx_bytes) },
> +	{ "rx_broadcast", E1000_STAT(stats.bprc) },
> +	{ "tx_broadcast", E1000_STAT(stats.bptc) },
> +	{ "rx_multicast", E1000_STAT(stats.mprc) },
> +	{ "tx_multicast", E1000_STAT(stats.mptc) },
>  	{ "rx_errors", E1000_STAT(net_stats.rx_errors) },
>  	{ "tx_errors", E1000_STAT(net_stats.tx_errors) },
>  	{ "tx_dropped", E1000_STAT(net_stats.tx_dropped) },

NAK -- you also need to remove the standard net stats, which are 
exported elsewhere


