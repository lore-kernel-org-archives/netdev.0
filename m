From: "David S. Miller" <davem@davemloft.net>
Subject: Re: [PATCH 2.6] ipvs - do not use skb_checksum_help, nf_reset
Date: Sat, 11 Sep 2004 17:39:52 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040911173952.5092aa65.davem@davemloft.net>
References: <Pine.LNX.4.58.0409111012030.1315@u.domain.uli>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@oss.sgi.com, wensong@linux-vs.org
Return-path: <netdev-bounce@oss.sgi.com>
To: Julian Anastasov <ja@ssi.bg>
In-Reply-To: <Pine.LNX.4.58.0409111012030.1315@u.domain.uli>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Sat, 11 Sep 2004 10:21:36 +0300 (EEST)
Julian Anastasov <ja@ssi.bg> wrote:

> - do not reset/destroy the nfct in IP_VS_XMIT, the intention is to
> reset the debugging field just to avoid log floods from nf_debug_ip_*
> functions, it is known that the out->in ipvs packets traverse hooks in
> non-standard way, eg. LOCAL_IN->LOCAL_OUT

Please add a generic nf_reset_debug() in linux/skbuff.h instead
of this version local to the IPVS code.

I'll apply a resubmitted full patch with this change made to it.

Thanks.
