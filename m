From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] sh_eth: make 'link' field of 'struct sh_eth_private'
 *int*
Date: Sun, 31 Mar 2013 19:44:54 -0400 (EDT)
Message-ID: <20130331.194454.590712799179779794.davem@davemloft.net>
References: <201304010011.04950.sergei.shtylyov@cogentembedded.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, nobuhiro.iwamatsu.yj@renesas.com,
	linux-sh@vger.kernel.org
To: sergei.shtylyov@cogentembedded.com
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <201304010011.04950.sergei.shtylyov@cogentembedded.com>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Date: Mon, 1 Apr 2013 00:11:04 +0400

> The 'link' field of 'struct sh_eth_private' has type 'enum phy_state' while the
> 'link' field of 'struct phy_device' is merely *int* (having values 0 and 1) and
> the former field gets assigned from the latter. Make the field match, getting
> rid of incorrectly used PHY_DOWN value in assignments/comparisons.  
> 
> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

Applied.
