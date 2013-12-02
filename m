From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [Patch v4] IPv6: Fixed support for blackhole and prohibit routes
Date: Mon, 2 Dec 2013 16:34:33 +0100
Message-ID: <20131202153433.GA3867@order.stressinduktion.org>
References: <1385994322-23117-1-git-send-email-kamala@aristanetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	linux-kernel@vger.kernel.org
To: Kamala R <kamala@aristanetworks.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1385994322-23117-1-git-send-email-kamala@aristanetworks.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Dec 02, 2013 at 07:55:21PM +0530, Kamala R wrote:
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

Looks good, thanks!

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
