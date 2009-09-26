From: Daniel Walker <dwalker@fifo99.com>
Subject: Re: [PATCH v3 net-next-2.6] cxgb3: Added private MAC address and
 provisioning packet handler for iSCSI
Date: Sat, 26 Sep 2009 12:22:39 -0700
Message-ID: <1253992959.20648.434.camel@desktop>
References: <200909261903.n8QJ3D2b000882@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, swise@opengridcomputing.com, divy@chelsio.com,
	rakesh@chelsio.com, michaelc@cs.wisc.edu,
	James.Bottomley@HansenPartnership.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: kxie@chelsio.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752716AbZIZTXK@vger.kernel.org>
In-Reply-To: <200909261903.n8QJ3D2b000882@localhost.localdomain>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2009-09-26 at 12:03 -0700, kxie@chelsio.com wrote:
>  enum {                 /* rx_offload flags */
>         T3_RX_CSUM      = 1 << 0,
>         T3_LRO          = 1 << 1,
>  };
>  
> +enum {
> +       LAN_MAC_IDX     = 0,
> +       SAN_MAC_IDX,
> +
> +       MAX_MAC_IDX
> +};

Why not name the enum and use it in the function declarations? I see
there are some other unnamed enums in there so you are following the
style in the file already.. However, naming the enum and using it allows
the input values to be known instead of just saying "int n", so I think
that's a better method..

Daniel
