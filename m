From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 00/13] mvneta Buffer Management and enhancements
Date: Tue, 24 Nov 2015 11:22:53 -0500 (EST)
Message-ID: <20151124.112253.2276973557484332376.davem@davemloft.net>
References: <1448178839-3541-1-git-send-email-mw@semihalf.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	netdev@vger.kernel.org, linux@arm.linux.org.uk,
	sebastian.hesselbarth@gmail.com, andrew@lunn.ch,
	jason@lakedaemon.net, thomas.petazzoni@free-electrons.com,
	gregory.clement@free-electrons.com, simon.guinot@sequanux.org,
	nadavh@marvell.com, alior@marvell.com, xswang@marvell.com,
	myair@marvell.com, nitroshift@yahoo.com, jaz@semihalf.com,
	tn@semihalf.com
To: mw@semihalf.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1448178839-3541-1-git-send-email-mw@semihalf.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


This patch series has a lot of problems.

The worst one is that you are mixing bug fixes and new
features/cleanups.

You cannot do that.

You _especially_ can't do that if you expect some of this stuff
to be submitted to -stable too.

Therefore you _must_ extract out the bug fixes, and submit those
against 'net'.  And you must then wait for 'net' to be merged
into 'net-next' before submitting the new feature patches.

Furthermore, you should explicitly show what tree you are targetting
your patches at, in your Subject lines.  In the form:

	Subject: [PATCH $(TREE) N/M]

Where $(TREE) is either 'net' or 'net-next'.

THanks.
