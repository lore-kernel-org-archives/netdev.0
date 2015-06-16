From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: Re: [PATCH 1/2] net: mvneta: introduce tx_csum_limit property
Date: Tue, 16 Jun 2015 12:00:34 +0200
Message-ID: <20150616120034.510b0030@free-electrons.com>
References: <1434378443-23029-1-git-send-email-simon.guinot@sequanux.org>
	<1434378443-23029-2-git-send-email-simon.guinot@sequanux.org>
	<20150615164952.4f2f4dab@free-electrons.com>
	<20150615155440.GS4853@kw.sim.vm.gnt>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jason Cooper <jason@lakedaemon.net>, Andrew Lunn <andrew@lunn.ch>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
	netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	stable@vger.kernel.org
To: Simon Guinot <simon.guinot@sequanux.org>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <20150615155440.GS4853@kw.sim.vm.gnt>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

On Mon, 15 Jun 2015 17:54:41 +0200, Simon Guinot wrote:

> > The current armada-370-neta would limit the HW checksumming features to
> > packets smaller than 1600 bytes, while a new armada-xp-neta would not
> > have this limit.
> 
> This was also my first idea. But by doing this, we take the risk of
> losing the HW checksumming feature with jumbo frames on some currently
> working Armada XP setups. This may happen for example if a user is able
> to update the kernel but not the on-board DTB. In order to fix a feature
> on a SoC, we are breaking the DTB-kernel compatibility for the very same
> feature on an another SoC. I am not sure it is OK.
> 
> Are you comfortable with that ?

It's either that, or keep a not-ideal solution for this problem. I'm
not a strong believer in the need of enforcing the DT as a stable ABI,
and I am not aware of anyone using Marvell platforms with a DTB that
isn't changed together with the kernel. So my preference goes to fixing
the problem properly, rather than doing non-ideal solutions.

Though this is just my own opinion, and I am not a maintainer of the
mach-mvebu platform.

Thomas
-- 
Thomas Petazzoni, CTO, Free Electrons
Embedded Linux, Kernel and Android engineering
http://free-electrons.com
