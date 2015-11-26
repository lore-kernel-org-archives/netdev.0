From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: Re: [PATCH v2 net 6/6] net: mvneta: enable IP checksum with jumbo
 frames for Armada 38x on Port0
Date: Thu, 26 Nov 2015 19:33:01 +0100
Message-ID: <20151126193301.67259f76@free-electrons.com>
References: <1448561293-16431-1-git-send-email-mw@semihalf.com>
	<1448561293-16431-7-git-send-email-mw@semihalf.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	netdev@vger.kernel.org, davem@davemloft.net,
	linux@arm.linux.org.uk, sebastian.hesselbarth@gmail.com,
	andrew@lunn.ch, jason@lakedaemon.net,
	gregory.clement@free-electrons.com, simon.guinot@sequanux.org,
	nadavh@marvell.com, alior@marvell.com, xswang@marvell.com,
	myair@marvell.com, nitroshift@yahoo.com, jaz@semihalf.com,
	tn@semihalf.com, <stable@vger.kernel.org>
To: Marcin Wojtas <mw@semihalf.com>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1448561293-16431-7-git-send-email-mw@semihalf.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Marcin,

On Thu, 26 Nov 2015 19:08:13 +0100, Marcin Wojtas wrote:
> The Ethernet controller found in the Armada 38x SoC's family support
> TCP/IP checksumming with frame sizes larger than 1600 bytes, however
> only on port 0.
> 
> This commit enables it by setting 'tx-csum-limit' to 9800B in
> 'ethernet@70000' node.
> 
> Signed-off-by: Marcin Wojtas <mw@semihalf.com>
> Cc: <stable@vger.kernel.org> # v3.18+

This and the previous patch is not a fix, and has no business going in
stable. It is enabling a better functionality, but it is clearly not a
fix.

Thomas
-- 
Thomas Petazzoni, CTO, Free Electrons
Embedded Linux, Kernel and Android engineering
http://free-electrons.com
