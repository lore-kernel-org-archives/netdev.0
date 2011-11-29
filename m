From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 3/4] NET: NETROM: Cleanup argument SIOCADDRT ioctl
 argument checking.
Date: Tue, 29 Nov 2011 01:18:09 -0500 (EST)
Message-ID: <20111129.011809.998010141029466939.davem@davemloft.net>
References: <cover.1322214950.git.ralf@linux-mips.org>
	<9f87aed932fc551c6f5c474b39d01fb337237a7e.1322214950.git.ralf@linux-mips.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-hams@vger.kernel.org,
	thomas@osterried.de
To: ralf@linux-mips.org
Return-path: <linux-hams-owner@vger.kernel.org>
In-Reply-To: <9f87aed932fc551c6f5c474b39d01fb337237a7e.1322214950.git.ralf@linux-mips.org>
Sender: linux-hams-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Ralf Baechle <ralf@linux-mips.org>
Date: Fri, 25 Nov 2011 09:09:00 +0000

> nr_route.ndigis is unsigned int so the nr_route.ndigis < 0 expression is
> never true and can be dropped.  Doing the nr_ax25_dev_get call later
> allows the nr_route.ndigis test to bail out without having to dev_put.
> 
> Signed-off-by: Ralf Baechle <ralf@linux-mips.org>

Applied.
