From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] cavium: thunder: Remove duplicate "netdev->name"
 logging output
Date: Thu, 29 Jun 2017 12:25:58 -0400 (EDT)
Message-ID: <20170629.122558.2257692860243246268.davem@davemloft.net>
References: <0ac1a144114eecd8c469027d6c91f453d61e1ade.1498560984.git.joe@perches.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: sgoutham@cavium.com, rric@kernel.org,
        linux-arm-kernel@lists.infradead.org, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
To: joe@perches.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <0ac1a144114eecd8c469027d6c91f453d61e1ade.1498560984.git.joe@perches.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Tue, 27 Jun 2017 03:56:54 -0700

> Using netdev_<level>(netdev, "%s: ...", netdev->name) duplicates the
> name in the output.  Remove those uses.
> 
> Miscellanea:
> 
> o Use the netif_<level> convenience macros at the same time
> 
> Signed-off-by: Joe Perches <joe@perches.com>

Applied to net-next.
