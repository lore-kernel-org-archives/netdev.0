From: David Miller <davem@davemloft.net>
Subject: Re: mpd client timeouts (bisected) 2.6.35-rc3
Date: Sun, 13 Jun 2010 17:14:42 -0700 (PDT)
Message-ID: <20100613.171442.226776182.davem@davemloft.net>
References: <4C149147.3080808@intel.com>
	<4C15414E.5090201@intel.com>
	<1276462246.2448.17.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: john.r.fastabend@intel.com, markus@trippelsdorf.de,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	yanmin_zhang@linux.intel.com, alex.shi@intel.com,
	tim.c.chen@intel.com
To: eric.dumazet@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1276462246.2448.17.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Sun, 13 Jun 2010 22:50:46 +0200

> Acked-by: Eric Dumazet <eric.dumazet@gmail.com>

Eric, please never ACK a patch in the same mail in which you are
posting new patch.  Patchwork won't add your ACK to the patchwork
entry you are ACK'ing because all of your text will go into a new
patchwork entry for the patch you are posting.

> BTW, David, it seems there is a double rxhash copy...
> 
> [PATCH] net: rxhash already set in __copy_skb_header
> 
> No need to copy rxhash again in __skb_clone()
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

I'll apply this, thanks.
