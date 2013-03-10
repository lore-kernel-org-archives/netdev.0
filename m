From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Patch net-next] tunnel: use iptunnel_xmit() again
Date: Sun, 10 Mar 2013 05:29:47 +0100
Message-ID: <1362889787.4051.14.camel@edumazet-glaptop>
References: <1362883119-4099-1-git-send-email-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Pravin B Shelar <pshelar@nicira.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	"David S. Miller" <davem@davemloft.net>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f52.google.com ([74.125.83.52]:40116 "EHLO
	mail-ee0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752000Ab3CJE3v (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Mar 2013 23:29:51 -0500
Received: by mail-ee0-f52.google.com with SMTP id b15so1642577eek.11
        for <netdev@vger.kernel.org>; Sat, 09 Mar 2013 20:29:50 -0800 (PST)
In-Reply-To: <1362883119-4099-1-git-send-email-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2013-03-10 at 10:38 +0800, Cong Wang wrote:
> From: Cong Wang <xiyou.wangcong@gmail.com>
> 
> With recent patches from Pravin, most tunnels can't use iptunnel_xmit()
> any more, due to ip_select_ident() and skb->ip_summed. But we can just
> move these operations out of iptunnel_xmit(), so that tunnels can
> use it again.
> 
> This by the way fixes a bug in vxlan (missing nf_reset()) for net-next.
> 
> Cc: Pravin B Shelar <pshelar@nicira.com>
> Cc: Stephen Hemminger <stephen@networkplumber.org>
> Cc: "David S. Miller" <davem@davemloft.net>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
> 
> ---

missing diffstat

otherwise, patch looks good to me

Acked-by: Eric Dumazet <edumazet@google.com>
