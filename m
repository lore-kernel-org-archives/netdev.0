From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ip_tunnel: fix possible rtable leak
Date: Thu, 05 Jun 2014 18:46:04 -0700 (PDT)
Message-ID: <20140605.184604.449700096883990839.davem@davemloft.net>
References: <20140606043437.f50f21cd56243ffa30165710@qrator.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kuznet@ms2.inr.ac.ru, jmorris@namei.org, yoshfuji@linux-ipv6.org,
	kaber@trash.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, trivial@kernel.org
To: ixaphire@qrator.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140606043437.f50f21cd56243ffa30165710@qrator.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Dmitry Popov <ixaphire@qrator.net>
Date: Fri, 6 Jun 2014 04:34:37 +0400

> ip_rt_put(rt) is always called in "error" branches above, but was missed in
> skb_cow_head branch. As rt is not yet bound to skb here we have to release it by 
> hand.
> 
> Signed-off-by: Dmitry Popov <ixaphire@qrator.net>

Applied, thanks.
