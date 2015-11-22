From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 07/13] bus: mvebu-mbus: provide api for obtaining IO and DRAM window information
Date: Sun, 22 Nov 2015 21:02:37 +0100
Message-ID: <5746764.cNlI6PeatM@wuerfel>
References: <1448178839-3541-1-git-send-email-mw@semihalf.com> <1448178839-3541-8-git-send-email-mw@semihalf.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Marcin Wojtas <mw@semihalf.com>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, thomas.petazzoni@free-electrons.com,
	andrew@lunn.ch, linux@arm.linux.org.uk, jason@lakedaemon.net,
	myair@marvell.com, jaz@semihalf.com, simon.guinot@sequanux.org,
	xswang@marvell.com, nadavh@marvell.com, alior@marvell.com,
	tn@semihalf.com, gregory.clement@free-electrons.com,
	nitroshift@yahoo.com, davem@davemloft.net,
	sebastian.hesselbarth@gmail.com
To: linux-arm-kernel@lists.infradead.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1448178839-3541-8-git-send-email-mw@semihalf.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sunday 22 November 2015 08:53:53 Marcin Wojtas wrote:
> This commit enables finding appropriate mbus window and obtaining its
> target id and attribute for given physical address in two separate
> routines, both for IO and DRAM windows. This functionality
> is needed for Armada XP/38x Network Controller's Buffer Manager and
> PnC configuration.
> 
> Signed-off-by: Marcin Wojtas <mw@semihalf.com>
> 
> [DRAM window information reference in LKv3.10]
> Signed-off-by: Evan Wang <xswang@marvell.com>
> 

It's too long ago to remember all the details, but I thought we
had designed this so the configuration can just be done by
describing it in DT. What am I missing?

	Arnd
