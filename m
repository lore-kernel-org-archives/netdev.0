From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH] add new iptables ipt_connbytes match
Date: Thu, 11 Aug 2005 15:42:04 -0700 (PDT)
Message-ID: <20050811.154204.102613246.davem@davemloft.net>
References: <20050811200349.GN5353@rama.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, netfilter-devel@lists.netfilter.org
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: laforge@netfilter.org
In-Reply-To: <20050811200349.GN5353@rama.de.gnumonks.org>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org

From: Harald Welte <laforge@netfilter.org>
Date: Thu, 11 Aug 2005 22:03:49 +0200

> +struct ipt_connbytes_info
> +{
> +	struct {
> +		u_int64_t from;	/* count to be matched */
> +		u_int64_t to;	/* count to be matched */
> +	} count;
> +	u_int8_t what;		/* ipt_connbytes_what */
> +	u_int8_t direction;	/* ipt_connbytes_direction */
> +};

Won't work in x86 --> x86_64 compat environments.
