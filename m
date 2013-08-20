From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tcp: set timestamps for restored skb-s
Date: Tue, 20 Aug 2013 13:08:18 -0700 (PDT)
Message-ID: <20130820.130818.1803264305462032520.davem@davemloft.net>
References: <1376665476-9683-1-git-send-email-avagin@openvz.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net
To: avagin@openvz.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1376665476-9683-1-git-send-email-avagin@openvz.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Andrey Vagin <avagin@openvz.org>
Date: Fri, 16 Aug 2013 19:04:36 +0400

> When the repair mode is turned off, the write queue seqs are
> updated so that the whole queue is considered to be 'already sent.
> 
> The "when" field must be set for such skb. It's used in tcp_rearm_rto
> for example. If the "when" field isn't set, the retransmit timeout can
> be calculated incorrectly and a tcp connected can stop for two minutes
> (TCP_RTO_MAX).
> 
> Acked-by: Pavel Emelyanov <xemul@parallels.com>
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
> Cc: James Morris <jmorris@namei.org>
> Cc: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
> Cc: Patrick McHardy <kaber@trash.net>
> Signed-off-by: Andrey Vagin <avagin@openvz.org>

Applied and queued up for -stable, thanks.
