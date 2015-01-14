From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] net/macb: improved ethtool statistics support
Date: Wed, 14 Jan 2015 00:26:14 -0500 (EST)
Message-ID: <20150114.002614.1397748285323961841.davem@davemloft.net>
References: <1421187351-27279-1-git-send-email-xander.huff@ni.com>
	<1421187351-27279-2-git-send-email-xander.huff@ni.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: nicolas.ferre@atmel.com, jaeden.amero@ni.com,
	rich.tollerton@ni.com, ben.shelton@ni.com, brad.mouring@ni.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: xander.huff@ni.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1421187351-27279-2-git-send-email-xander.huff@ni.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Xander Huff <xander.huff@ni.com>
Date: Tue, 13 Jan 2015 16:15:51 -0600

> Currently `ethtool -S` simply returns "no stats available". It
> would be more useful to see what the various ethtool statistics
> registers' values are. This change implements get_ethtool_stats,
> get_strings, and get_sset_count functions to accomplish this.
> 
> Read all GEM statistics registers and sum them into
> macb.ethtool_stats. Add the necessary infrastructure to make this
> accessible via `ethtool -S`.
> 
> Update gem_update_stats to utilize ethtool_stats.
> 
> Signed-off-by: Xander Huff <xander.huff@ni.com>

Applied.
