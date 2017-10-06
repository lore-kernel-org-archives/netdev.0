From: David Miller <davem@davemloft.net>
Subject: Re: [RESEND PATCH 7/7] net: qrtr: Support decoding incoming v2
 packets
Date: Thu, 05 Oct 2017 18:05:39 -0700 (PDT)
Message-ID: <20171005.180539.381799694621402344.davem@davemloft.net>
References: <20171005035105.14677-1-bjorn.andersson@linaro.org>
        <20171005035105.14677-8-bjorn.andersson@linaro.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        linux-arm-msm@vger.kernel.org, clew@codeaurora.org
To: bjorn.andersson@linaro.org
Return-path: <linux-arm-msm-owner@vger.kernel.org>
In-Reply-To: <20171005035105.14677-8-bjorn.andersson@linaro.org>
Sender: linux-arm-msm-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Bjorn Andersson <bjorn.andersson@linaro.org>
Date: Wed,  4 Oct 2017 20:51:05 -0700

> +/**
> + * struct qrtr_hdr_v2 - (I|R)PCrouter packet header later versions
> + * @version: protocol version
> + * @type: packet type; one of QRTR_TYPE_*
> + * @flags: bitmask of QRTR_FLAGS_*
> + * @optlen: length of optional header data
> + * @size: length of packet, excluding this header and optlen
> + * @src_node_id: source node
> + * @src_port_id: source port
> + * @dst_node_id: destination node
> + * @dst_port_id: destination port
> + */
> +struct qrtr_hdr_v2 {
> +	u8 version;
> +	u8 type;
> +	u8 flags;
> +	u8 optlen;
> +	__le32 size;
> +	__le16 src_node_id;
> +	__le16 src_port_id;
> +	__le16 dst_node_id;
> +	__le16 dst_port_id;
> +} __packed;

__packed should be only used when it is provably necessary, and it
should not be needed here.
