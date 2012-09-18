From: David Miller <davem@davemloft.net>
Subject: Re: [patch net] sky2: fix rx filter setup on link up
Date: Tue, 18 Sep 2012 16:25:53 -0400 (EDT)
Message-ID: <20120918.162553.2196748185499351536.davem@davemloft.net>
References: <20120917091214.5cd9b0f5@nehalam.linuxnetplumber.net>
	<20120917204724.GA1749@minipsycho.orion>
	<20120917141507.7528b3ee@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jiri@resnulli.us, netdev@vger.kernel.org, mlindner@marvell.com,
	linux-kernel@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20120917141507.7528b3ee@nehalam.linuxnetplumber.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Mon, 17 Sep 2012 14:15:07 -0700

> Are you sure it isn't IPv6 or something else setting additional mulitcast
> addresses. You may need to instrument the set_multicast call.

I'm confident in Jiri's analysis and patch and it's clear the hardware
is doing this on it's own, so please take his bug fix seriously.
