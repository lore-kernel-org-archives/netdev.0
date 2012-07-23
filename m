From: "Allan, Bruce W" <bruce.w.allan@intel.com>
Subject: RE: [E1000-devel] [PATCH net-next 3/4] e1000e: advertise transmit
 time	stamping
Date: Mon, 23 Jul 2012 16:07:31 +0000
Message-ID: <804857E1F29AAC47BF68C404FC60A1842EAA9176@ORSMSX102.amr.corp.intel.com>
References: <cover.1342976654.git.richardcochran@gmail.com>
 <e0e31f0229b5bfda1684122498b4d6fb3195cf26.1342976654.git.richardcochran@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "e1000-devel@lists.sourceforge.net"
	<e1000-devel@lists.sourceforge.net>,
	Willem de Bruijn <willemb@google.com>,
	David Miller <davem@davemloft.net>
To: Richard Cochran <richardcochran@gmail.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:41930 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752855Ab2GWQHt convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jul 2012 12:07:49 -0400
In-Reply-To: <e0e31f0229b5bfda1684122498b4d6fb3195cf26.1342976654.git.richardcochran@gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Richard Cochran [mailto:richardcochran@gmail.com]
> Sent: Sunday, July 22, 2012 10:16 AM
> To: netdev@vger.kernel.org
> Cc: e1000-devel@lists.sourceforge.net; Willem de Bruijn; David Miller
> Subject: [E1000-devel] [PATCH net-next 3/4] e1000e: advertise transmit
> time stamping
> 
> This driver now offers software transmit time stamping, so it should
> advertise that fact via ethtool. Compile tested only.
> 
> Signed-off-by: Richard Cochran <richardcochran@gmail.com>
> 
> Cc: Willem de Bruijn <willemb@google.com>
> Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> Cc: e1000-devel@lists.sourceforge.net
> ---
>  drivers/net/ethernet/intel/e1000e/ethtool.c |    1 +
>  1 files changed, 1 insertions(+), 0 deletions(-)
> 
> diff --git a/drivers/net/ethernet/intel/e1000e/ethtool.c
> b/drivers/net/ethernet/intel/e1000e/ethtool.c
> index 105d554..0349e24 100644
> --- a/drivers/net/ethernet/intel/e1000e/ethtool.c
> +++ b/drivers/net/ethernet/intel/e1000e/ethtool.c
> @@ -2061,6 +2061,7 @@ static const struct ethtool_ops e1000_ethtool_ops
> = {
>  	.get_coalesce		= e1000_get_coalesce,
>  	.set_coalesce		= e1000_set_coalesce,
>  	.get_rxnfc		= e1000_get_rxnfc,
> +	.get_ts_info		= ethtool_op_get_ts_info,
>  };
> 
>  void e1000e_set_ethtool_ops(struct net_device *netdev)

Thanks Richard.  I have a similar patch amongst the PTP 1588 work I'm currently doing
for e1000e, but this one is good for now.

Acked-by: Bruce Allan <bruce.w.allan@intel.com>
