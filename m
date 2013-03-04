From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [RFC PATCH 1/5] net: implement support for low latency socket
 polling
Date: Mon, 4 Mar 2013 07:23:35 +0000 (UTC)
Message-ID: <kh1i5m$jqp$1@ger.gmane.org>
References: <20130227175549.10611.82188.stgit@gitlad.jf.intel.com>
 <20130227175555.10611.42794.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, e1000-devel@lists.sourceforge.net
To: linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 27 Feb 2013 at 17:55 GMT, Eliezer Tamir <eliezer.tamir@linux.jf.intel.com> wrote:
> +static inline void skb_mark_ll(struct napi_struct *napi, struct sk_buff *skb)
> +{
> +	skb->dev_ref = napi;
> +}
> +
> +static inline void sk_mark_ll(struct sock *sk, struct sk_buff *skb)
> +{
> +	if (skb->dev_ref)
> +		sk->dev_ref = skb->dev_ref;
> +
> +}


It is actually easier to read the code without making them be
functions...
