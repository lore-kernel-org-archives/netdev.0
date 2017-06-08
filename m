From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH net-next 2/8] qed: Revise ll2 Rx completion
Date: Thu, 08 Jun 2017 19:24:33 -0400 (EDT)
Message-ID: <20170608.192433.1559179766198812724.davem@davemloft.net>
References: <20170608161323.7597-1-Yuval.Mintz@cavium.com>
        <20170608161323.7597-3-Yuval.Mintz@cavium.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Michal.Kalderon-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org
To: Yuval.Mintz-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20170608161323.7597-3-Yuval.Mintz-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Yuval Mintz <Yuval.Mintz-YGCgFSpz5w/QT0dZR+AlfA@public.gmane.org>
Date: Thu, 8 Jun 2017 19:13:17 +0300

> +struct qed_ll2_comp_rx_data {
> +	u8 connection_handle;
> +	void *cookie;
> +	dma_addr_t rx_buf_addr;
> +	u16 parse_flags;
> +	u16 vlan;
> +	bool b_last_packet;
> +
> +	union {
> +		u8 placement_offset;
> +		u8 data_length_error;
> +	} u;
> +	union {
> +		u16 packet_length;
> +		u16 data_length;
> +	} length;
> +
> +	u32 opaque_data_0;
> +	u32 opaque_data_1;
> +
> +	/* GSI only */
> +	u32 gid_dst[4];
> +	u16 qp_id;
> +};
> +

Again, a lot of unnecessary padding in the structure due to suboptimal
member ordering.

Please fix this.

Thank you.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
