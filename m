From: David Miller <davem@davemloft.net>
Subject: Re: Remaining bits for basic support of LDP
Date: Mon, 02 Feb 2009 13:45:30 -0800 (PST)
Message-ID: <20090202.134530.63616213.davem@davemloft.net>
References: <20090202213953.GB16069@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tony@atomide.com, linux-omap@vger.kernel.org,
	netdev@vger.kernel.org
To: linux@arm.linux.org.uk
Return-path: <linux-omap-owner@vger.kernel.org>
In-Reply-To: <20090202213953.GB16069@n2100.arm.linux.org.uk>
Sender: linux-omap-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Russell King - ARM Linux <linux@arm.linux.org.uk>
Date: Mon, 2 Feb 2009 21:39:53 +0000

> The patch to fix these issues would seem to be relatively small (12
> lines in the smc911x and one line change in board-ldp.c) - is it
> something we want done for -rc4 or do we scrap the ethernet support 
> on the LDP until the SMSC driver has been merged ?
> 
> Obviously, having working ethernet would be helpful, and since it was
> half heartedly merged when the initial OMAP3 stuff went upstream we
> should do something with it one way or another.

Well, the SMSC driver is there already in the tree.

The only thing not currently being scheduled to hit
2.6.29-rcX are the recent changes to support platform
specified interrupt flags and all of that stuff.

If you want, we can look into pushing that work into
2.6.29-rcX
