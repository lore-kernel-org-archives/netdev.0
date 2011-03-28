From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: use CHECKSUM_NONE instead of magic number
Date: Sun, 27 Mar 2011 18:37:19 -0700 (PDT)
Message-ID: <20110327.183719.242146299.davem@davemloft.net>
References: <1301152230-4897-1-git-send-email-cesarb@cesarb.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru, pekkas@netcore.fi,
	jmorris@namei.org, yoshfuji@linux-ipv6.org, kaber@trash.net,
	eric.dumazet@gmail.com, Tristram.Ha@micrel.com,
	linux-kernel@vger.kernel.org
To: cesarb@cesarb.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1301152230-4897-1-git-send-email-cesarb@cesarb.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Cesar Eduardo Barros <cesarb@cesarb.net>
Date: Sat, 26 Mar 2011 12:10:30 -0300

> Two places in the kernel were doing skb->ip_summed = 0.
> 
> Change both to skb->ip_summed = CHECKSUM_NONE, which is more readable.
> 
> Signed-off-by: Cesar Eduardo Barros <cesarb@cesarb.net>

Applied, thank you.
