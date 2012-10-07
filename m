From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH V2] net: Fix skb_under_panic oops in
 neigh_resolve_output
Date: Sun, 07 Oct 2012 14:43:19 -0400 (EDT)
Message-ID: <20121007.144319.1790853256019640271.davem@davemloft.net>
References: <1349500215-22765-1-git-send-email-ramesh.nagappa@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, edumazet@google.com, ebiederm@xmission.com,
	xemul@parallels.com, linux-kernel@vger.kernel.org,
	ramesh.nagappa@ericsson.com
To: ramesh.nagappa@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1349500215-22765-1-git-send-email-ramesh.nagappa@gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: ramesh.nagappa@gmail.com
Date: Fri,  5 Oct 2012 22:10:15 -0700

> The retry loop in neigh_resolve_output() and neigh_connected_output()
> call dev_hard_header() with out reseting the skb to network_header.
> This causes the retry to fail with skb_under_panic. The fix is to
> reset the network_header within the retry loop.
> 
> Signed-off-by: Ramesh Nagappa <ramesh.nagappa@ericsson.com>
> Reviewed-by: Shawn Lu <shawn.lu@ericsson.com>
> Reviewed-by: Robert Coulson <robert.coulson@ericsson.com>
> Reviewed-by: Billie Alsup <billie.alsup@ericsson.com>

Applied and queued up for -stable, thanks.
