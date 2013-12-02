From: David Miller <davem@davemloft.net>
Subject: Re: [Patch v4] IPv6: Fixed support for blackhole and prohibit
 routes
Date: Mon, 02 Dec 2013 17:16:54 -0500 (EST)
Message-ID: <20131202.171654.1682815174948392171.davem@davemloft.net>
References: <1385994322-23117-1-git-send-email-kamala@aristanetworks.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: hannes@stressinduktion.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: kamala@aristanetworks.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1385994322-23117-1-git-send-email-kamala@aristanetworks.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Kamala R <kamala@aristanetworks.com>
Date: Mon,  2 Dec 2013 19:55:21 +0530

> The behaviour of blackhole and prohibit routes has been corrected by setting
> the input and output pointers of the dst variable appropriately. For
> blackhole routes, they are set to dst_discard and to ip6_pkt_discard and
> ip6_pkt_discard_out respectively for prohibit routes.
> 
> ipv6: ip6_pkt_prohibit(_out) should not depend on
> CONFIG_IPV6_MULTIPLE_TABLES
> 
> We need ip6_pkt_prohibit(_out) available without
> CONFIG_IPV6_MULTIPLE_TABLES
> 
> Signed-off-by: Kamala R <kamala@aristanetworks.com>

Applied and queued up for -stable, thanks.
