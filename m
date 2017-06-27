From: Stephen Hemminger <stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org>
Subject: Re: [PATCH iproute2 V1 3/6] rdma: Add device capability parsing
Date: Tue, 27 Jun 2017 16:04:49 -0700
Message-ID: <20170627160449.58e40a9f@xeon-e3>
References: <20170627143920.28020-1-leon@kernel.org>
        <20170627143920.28020-4-leon@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        Ariel Almog <ariela-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Dennis Dalessandro <dennis.dalessandro-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>,
        Linux RDMA <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Linux Netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170627143920.28020-4-leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Tue, 27 Jun 2017 17:39:17 +0300
Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org> wrote:

> +static const char *dev_caps[64] = {
> +	"RESIZE_MAX_WR",
> +	"BAD_PKEY_CNTR",
> +	"BAD_QKEY_CNTR",
> +	"RAW_MULTI",
> +	"AUTO_PATH_MIG",
> +	"CHANGE_PHY_PORT",
> +	"UD_AV_PORT_ENFORCE",
> +	"CURR_QP_STATE_MOD",
> +	"SHUTDOWN_PORT",
> +	"INIT_TYPE",
> +	"PORT_ACTIVE_EVENT",
> +	"SYS_IMAGE_GUID",
> +	"RC_RNR_NAK_GEN",
> +	"SRQ_RESIZE",
> +	"N_NOTIFY_CQ",
> +	"LOCAL_DMA_LKEY",
> +	"RESERVED",
> +	"MEM_WINDOW",
> +	"UD_IP_CSUM",
> +	"UD_TSO",
> +	"XRC",
> +	"MEM_MGT_EXTENSIONS",
> +	"BLOCK_MULTICAST_LOOPBACK",
> +	"MEM_WINDOW_TYPE_2A",
> +	"MEM_WINDOW_TYPE_2B",
> +	"RC_IP_CSUM",
> +	"RAW_IP_CSUM",
> +	"CROSS_CHANNEL",
> +	"MANAGED_FLOW_STEERING",
> +	"SIGNATURE_HANDOVER",
> +	"ON_DEMAND_PAGING",
> +	"SG_GAPS_REG",
> +	"VIRTUAL_FUNCTION",
> +	"RAW_SCATTER_FCS",
> +	"RDMA_NETDEV_OPA_VNIC",
> +};

Please use array initializer so that header and capabilities don't get different values.
Are the bit values in some rdma header file?
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
