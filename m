From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 1/4] NET: AX.25: Check ioctl arguments to avoid
 overflows further down the road.
Date: Tue, 29 Nov 2011 01:17:55 -0500 (EST)
Message-ID: <20111129.011755.811907405309581515.davem@davemloft.net>
References: <cover.1322214950.git.ralf@linux-mips.org>
	<1d2adcd4eadb1f42926734cca5886dfad258aeb6.1322214950.git.ralf@linux-mips.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-hams@vger.kernel.org,
	xi.wang@gmail.com, jreuter@yaina.de, alan@lxorguk.ukuu.org.uk,
	thomas@osterried.de
To: ralf@linux-mips.org
Return-path: <linux-hams-owner@vger.kernel.org>
In-Reply-To: <1d2adcd4eadb1f42926734cca5886dfad258aeb6.1322214950.git.ralf@linux-mips.org>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ralf Baechle <ralf@linux-mips.org>
Date: Thu, 24 Nov 2011 16:12:59 +0000

> Very large, nonsenical arguments or use in very extreme conditions could
> result in integer overflows.  Check ioctls arguments to avoid such
> overflows and return -EINVAL for too large arguments.
> 
> To allow the use of AX.25 for even the most extreme setup (think packet
> radio to the Phase 5E mars probe) we make no further attempt to clamp the
> argument range.
> 
> Originally reported by Fan Long <longfancn@gmail.com> and a first patch
> was sent by Xi Wang <xi.wang@gmail.com>.
> 
> Signed-off-by: Ralf Baechle <ralf@linux-mips.org>

Applied.
