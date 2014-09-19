From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] 3c59x: Fix bad offset spec in skb_frag_dma_map
Date: Fri, 19 Sep 2014 16:29:26 -0400 (EDT)
Message-ID: <20140919.162926.1782273820747045814.davem@davemloft.net>
References: <alpine.LRH.2.11.1409160209280.21050@adalberg.ut.ee>
	<1410959085-7351-1-git-send-email-nhorman@tuxdriver.com>
	<1410959085-7351-2-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	mroos@linux.ee
To: nhorman@tuxdriver.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1410959085-7351-2-git-send-email-nhorman@tuxdriver.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Neil Horman <nhorman@tuxdriver.com>
Date: Wed, 17 Sep 2014 09:04:45 -0400

> Recently aded the use of skb_frag_dma_map to 3c59x, but didn't realize it
> automatically included the frag_offset internally, as well as provided an option
> to specify an extra offset in the parameter list.  We need to specify an offset
> of 0 in the parameter list to avoid skb corruption that results in lost
> connections.
> 
> Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
> CC: Linux Kernel list <linux-kernel@vger.kernel.org>
> CC: "David S. Miller" <davem@davemloft.net>
> CC: Meelis Roos <mroos@linux.ee>
> Tested-by: Meelis Roos <mroos@linux.ee>

Applied.
