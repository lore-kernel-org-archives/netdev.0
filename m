From: Govindarajulu Varadarajan <gvaradar@cisco.com>
Subject: Re: [PATCH net-next] enic: reduce ioread in devcmd2
Date: Tue, 25 Aug 2015 14:01:09 +0530 (IST)
Message-ID: <alpine.LNX.2.03.1508251359320.21182@cisco.com>
References: <1440490795-6888-1-git-send-email-_govind@gmx.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: davem@davemloft.net, netdev@vger.kernel.org, ssujith@cisco.com,
	benve@cisco.com
To: Govindarajulu Varadarajan <_govind@gmx.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bgl-iport-2.cisco.com ([72.163.197.26]:25118 "EHLO
	bgl-iport-2.cisco.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751726AbbHYIl0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Aug 2015 04:41:26 -0400
In-Reply-To: <1440490795-6888-1-git-send-email-_govind@gmx.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 25 Aug 2015, Govindarajulu Varadarajan wrote:

> posted_index is RO in firmware. We need not do ioread everytime to get
> posted index. Store posted index locally.
>
> Signed-off-by: Govindarajulu Varadarajan <_govind@gmx.com>
> ---
> diff --git a/drivers/net/ethernet/cisco/enic/vnic_wq.h b/drivers/net/ethernet/cisco/enic/vnic_wq.h
> index 8944af9..0120961 100644
> --- a/drivers/net/ethernet/cisco/enic/vnic_wq.h
> +++ b/drivers/net/ethernet/cisco/enic/vnic_wq.h
> @@ -97,6 +97,7 @@ struct devcmd2_controller {
> 	int color;
> 	struct vnic_dev_ring results_ring;
> 	struct vnic_wq wq;
> +	u32 posted;

I need to initialize posted in vnic_dev_init_devcmd2. Ignore this patch.
I will send v2.
