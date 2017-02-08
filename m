From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/3 net-next] enic: add devcmds for vxlan offload
Date: Wed, 08 Feb 2017 14:56:16 -0500 (EST)
Message-ID: <20170208.145616.1950352200402120604.davem@davemloft.net>
References: <20170208072825.3144-1-gvaradar@cisco.com>
        <20170208072825.3144-2-gvaradar@cisco.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, benve@cisco.com
To: gvaradar@cisco.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:58766 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751415AbdBHUvG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2017 15:51:06 -0500
In-Reply-To: <20170208072825.3144-2-gvaradar@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Govindarajulu Varadarajan <gvaradar@cisco.com>
Date: Tue,  7 Feb 2017 23:28:23 -0800

> diff --git a/drivers/net/ethernet/cisco/enic/vnic_dev.c b/drivers/net/ethernet/cisco/enic/vnic_dev.c
> index 8f27df3207bc..9b3d670e1aa9 100644
> --- a/drivers/net/ethernet/cisco/enic/vnic_dev.c
> +++ b/drivers/net/ethernet/cisco/enic/vnic_dev.c
> @@ -1247,3 +1247,45 @@ int vnic_dev_classifier(struct vnic_dev *vdev, u8 cmd, u16 *entry,
>  
>  	return ret;
>  }
> +
> +int vnic_dev_overlay_offload_ctrl(struct vnic_dev *vdev, u8 overlay, u8 config)
> +{
> +	u64 a0;
> +	u64 a1;
> +	int wait = 1000;
> +	int ret;
> +
> +	a0 = overlay;
> +	a1 = config;

Please order local variable declarations from longest to shortest line.
And you can make these helpers more compact by doing the assignment in
the declaration:

	u64 a0 = overlay;
	u64 a1 = config;
	int wait = 1000;
	int ret;
