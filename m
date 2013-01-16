From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] 6lowpan: Handle uncompressed IPv6 packets over
 6LoWPAN
Date: Wed, 16 Jan 2013 16:22:14 -0500 (EST)
Message-ID: <20130116.162214.444431638469568669.davem@davemloft.net>
References: <1358315037-10043-1-git-send-email-alan@signal11.us>
	<1358315037-10043-3-git-send-email-alan@signal11.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alex.bluesman.smirnov@gmail.com, dbaryshkov@gmail.com,
	linux-zigbee-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, tony.cheneau@amnesiak.org,
	eric.dumazet@gmail.com
To: alan@signal11.us
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1358315037-10043-3-git-send-email-alan@signal11.us>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alan Ott <alan@signal11.us>
Date: Wed, 16 Jan 2013 00:43:57 -0500

> +		local_skb = skb_copy_expand(skb, NET_SKB_PAD - 1,
> +						skb_tailroom(skb), GFP_ATOMIC);

This is not indented properly.

When a function call spans multiple lines, the second and subsequent
lines should be indented to the column right after the openning
parenthesis of the call itself, using a combination of TAB and
SPC characters as needed.
