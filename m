From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] tcp: Modify the condition for the first skb to collapse
Date: Mon, 17 Jun 2013 03:29:22 -0700
Message-ID: <1371464962.3252.181.camel@edumazet-glaptop>
References: <1371478739.10495.5.camel@chenjun-workstation>
	 <1371456935.3252.177.camel@edumazet-glaptop>
	 <1371490190.28418.6.camel@chenjun-workstation>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: ycheng@google.com, ncardwell@google.com, edumazet@google.com,
	netdev@vger.kernel.org, Linux Kernel <linux-kernel@vger.kernel.org>
To: Jun Chen <jun.d.chen@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1371490190.28418.6.camel@chenjun-workstation>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2013-06-17 at 13:29 -0400, Jun Chen wrote:
> > 
> hi,
> When the condition of tcp_win_from_space(skb->truesize) > skb->len is
> true but the before(start, TCP_SKB_CB(skb)->seq) is also true, the final
> condition will be true. The follow line:
> int offset = start - TCP_SKB_CB(skb)->seq;
> BUG_ON(offset < 0);
> this BUG_ON will be triggered.
> 

Really this should never happen, we must track what's happening here.

Are you using a pristine kernel, without any patches ?

Are you able to reproduce this bug in a short amount of time ?

What kind of driver is in use ? (your stack trace was truncated)
