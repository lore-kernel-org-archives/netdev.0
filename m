From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH v4 iproute2 2/7] rdma: Add dev object
Date: Tue, 15 Aug 2017 09:12:05 -0700
Message-ID: <20170815091205.2c39ea91@xeon-e3>
References: <20170815130020.29509-1-leonro@mellanox.com>
        <20170815130020.29509-3-leonro@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Doug Ledford <dledford@redhat.com>, linux-rdma@vger.kernel.org,
        Dennis Dalessandro <dennis.dalessandro@intel.com>,
        Jason Gunthorpe <jgunthorpe@obsidianresearch.com>,
        Jiri Pirko <jiri@mellanox.com>,
        Ariel Almog <ariela@mellanox.com>,
        Linux Netdev <netdev@vger.kernel.org>
To: Leon Romanovsky <leonro@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f50.google.com ([74.125.83.50]:33536 "EHLO
        mail-pg0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752682AbdHOQMN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 15 Aug 2017 12:12:13 -0400
Received: by mail-pg0-f50.google.com with SMTP id u5so8350592pgn.0
        for <netdev@vger.kernel.org>; Tue, 15 Aug 2017 09:12:13 -0700 (PDT)
In-Reply-To: <20170815130020.29509-3-leonro@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 15 Aug 2017 16:00:15 +0300
Leon Romanovsky <leonro@mellanox.com> wrote:

> +
> +static const char *dev_caps_to_str(uint32_t idx)
> +{
> +	uint64_t cap = 1 << idx;
> +
> +	switch (cap) {
> +	case RDMA_DEV_RESIZE_MAX_WR: return "RESIZE_MAX_WR";
> +	case RDMA_DEV_BAD_PKEY_CNTR: return "BAD_PKEY_CNTR";
> +	case RDMA_DEV_BAD_QKEY_CNTR: return "BAD_QKEY_CNTR";
> +	case RDMA_DEV_RAW_MULTI: return "RAW_MULTI";
> +	case RDMA_DEV_AUTO_PATH_MIG: return "AUTO_PATH_MIG";
> +	case RDMA_DEV_CHANGE_PHY_PORT: return "CHANGE_PHY_POR";
> +	case RDMA_DEV_UD_AV_PORT_ENFORCE: return "UD_AV_PORT_ENFORCE";
> +	case RDMA_DEV_CURR_QP_STATE_MOD: return "CURR_QP_STATE_MOD";
> +	case RDMA_DEV_SHUTDOWN_PORT: return "SHUTDOWN_PORT";
> +	case RDMA_DEV_INIT_TYPE: return "INIT_TYPE";
> +	case RDMA_DEV_PORT_ACTIVE_EVENT: return "PORT_ACTIVE_EVENT";
> +	case RDMA_DEV_SYS_IMAGE_GUID: return "SYS_IMAGE_GUID";
> +	case RDMA_DEV_RC_RNR_NAK_GEN: return "RC_RNR_NAK_GEN";
> +	case RDMA_DEV_SRQ_RESIZE: return "SRQ_RESIZE";
> +	case RDMA_DEV_N_NOTIFY_CQ: return "N_NOTIFY_CQ";
> +	case RDMA_DEV_LOCAL_DMA_LKEY: return "LOCAL_DMA_LKEY";
> +	case RDMA_DEV_MEM_WINDOW: return "MEM_WINDOW";
> +	case RDMA_DEV_UD_IP_CSUM: return "UD_IP_CSUM";
> +	case RDMA_DEV_UD_TSO: return "UD_TSO";
> +	case RDMA_DEV_XRC: return "XRC";
> +	case RDMA_DEV_MEM_MGT_EXTENSIONS: return "MEM_MGT_EXTENSIONS";
> +	case RDMA_DEV_BLOCK_MULTICAST_LOOPBACK:
> +					return "BLOCK_MULTICAST_LOOPBACK";
> +	case RDMA_DEV_MEM_WINDOW_TYPE_2A: return "MEM_WINDOW_TYPE_2A";
> +	case RDMA_DEV_MEM_WINDOW_TYPE_2B: return "MEM_WINDOW_TYPE_2B";
> +	case RDMA_DEV_RC_IP_CSUM: return "RC_IP_CSUM";
> +	case RDMA_DEV_RAW_IP_CSUM: return "RAW_IP_CSUM";
> +	case RDMA_DEV_CROSS_CHANNEL: return "CROSS_CHANNEL";
> +	case RDMA_DEV_MANAGED_FLOW_STEERING: return "MANAGED_FLOW_STEERING";
> +	case RDMA_DEV_SIGNATURE_HANDOVER: return "SIGNATURE_HANDOVER";
> +	case RDMA_DEV_ON_DEMAND_PAGING: return "ON_DEMAND_PAGING";
> +	case RDMA_DEV_SG_GAPS_REG: return "SG_GAPS_REG";
> +	case RDMA_DEV_VIRTUAL_FUNCTION: return "VIRTUAL_FUNCTION";
> +	case RDMA_DEV_RAW_SCATTER_FCS: return "RAW_SCATTER_FCS";
> +	case RDMA_DEV_RDMA_NETDEV_OPA_VNIC: return "RDMA_NETDEV_OPA_VNIC";
> +	default: return "UNKNOWN";
> +	}

Could this be a table in future versions?
