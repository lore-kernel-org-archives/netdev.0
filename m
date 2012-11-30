From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] 6lowpan: consider checksum bytes in fragmentation
 threshold
Date: Fri, 30 Nov 2012 12:19:37 -0500 (EST)
Message-ID: <20121130.121937.1126518481722222177.davem@davemloft.net>
References: <504EA95C.9010003@signal11.us>
	<1354240544-22214-1-git-send-email-alan@signal11.us>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: alex.bluesman.smirnov@gmail.com, dbaryshkov@gmail.com,
	linux-zigbee-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: alan@signal11.us
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1354240544-22214-1-git-send-email-alan@signal11.us>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Alan Ott <alan@signal11.us>
Date: Thu, 29 Nov 2012 20:55:44 -0500

> Change the threshold for framentation of a lowpan packet from
> using the MTU size to now use the MTU size minus the checksum length,
> which is added by the hardware. For IEEE 802.15.4, this effectively
> changes it from 127 bytes to 125 bytes.
> 
> Signed-off-by: Alan Ott <alan@signal11.us>

Applied.
