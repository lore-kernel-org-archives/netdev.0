From: David Miller <davem@davemloft.net>
Subject: Re: mpd client timeouts (bisected) 2.6.35-rc3
Date: Sun, 13 Jun 2010 17:13:18 -0700 (PDT)
Message-ID: <20100613.171318.193707256.davem@davemloft.net>
References: <20100612.145835.123986343.davem@davemloft.net>
	<4C149147.3080808@intel.com>
	<4C15414E.5090201@intel.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: markus@trippelsdorf.de, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, yanmin_zhang@linux.intel.com,
	alex.shi@intel.com, tim.c.chen@intel.com
To: john.r.fastabend@intel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4C15414E.5090201@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: John Fastabend <john.r.fastabend@intel.com>
Date: Sun, 13 Jun 2010 13:36:30 -0700

> Needed to set the wcard bit in copy_skb_header otherwise it will not
> be cleared when called from skb_clone.  Which then hits the loopback
> device gets pushed into the rx path and is eventually dropped. The
> following patch fixes this. Hopefully, this is easy and fast enough
> for you Dave.
> 
> 
> [PATCH] net: fix deliver_no_wcard regression on loopback device
> 
> deliver_no_wcard is not being set in skb_copy_header.
> In the skb_cloned case it is not being cleared and
> may cause the skb to be dropped when the loopback device
> pushes it back up the stack.
> 
> Signed-off-by: John Fastabend <john.r.fastabend@intel.com>

Applied, but your email client corrupted this patch in many
ways.  Please correct this for next time, thanks.
