From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net/ping: handle protocol mismatching scenario
Date: Mon, 24 Nov 2014 16:48:42 -0500 (EST)
Message-ID: <20141124.164842.1289257824447246212.davem@davemloft.net>
References: <1416858248-29258-1-git-send-email-a17711@motorola.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, kuznet@ms2.inr.ac.ru,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	netdev@vger.kernel.org, stable@vger.kernel.org, gbjc64@motorola.com
To: a17711@motorola.com
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1416858248-29258-1-git-send-email-a17711@motorola.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Jane Zhou <a17711@motorola.com>
Date: Mon, 24 Nov 2014 11:44:08 -0800

> ping_lookup() may return a wrong sock if sk_buff's and sock's protocols
> dont' match. For example, sk_buff's protocol is ETH_P_IPV6, but sock's
> sk_family is AF_INET, in that case, if sk->sk_bound_dev_if is zero, a wrong
> sock will be returned.
> the fix is to "continue" the searching, if no matching, return NULL.
> 
> Cc: "David S. Miller" <davem@davemloft.net>
> Cc: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
> Cc: James Morris <jmorris@namei.org>
> Cc: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
> Cc: Patrick McHardy <kaber@trash.net>
> Cc: netdev@vger.kernel.org
> Cc: stable@vger.kernel.org
> Signed-off-by: Jane Zhou <a17711@motorola.com>
> Signed-off-by: Yiwei Zhao <gbjc64@motorola.com>

Applied, thank you.
