From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: Re: [PATCH v3 3/3] ARM: mvebu: disable IP checksum with jumbo
 frames for Armada 370
Date: Tue, 30 Jun 2015 16:08:29 +0200
Message-ID: <20150630160829.7bec1a8f@free-electrons.com>
References: <1435673149-12599-1-git-send-email-simon.guinot@sequanux.org>
	<1435673149-12599-4-git-send-email-simon.guinot@sequanux.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Jason Cooper <jason@lakedaemon.net>,
	Andrew Lunn <andrew@lunn.ch>,
	Gregory Clement <gregory.clement@free-electrons.com>,
	Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>,
	netdev@vger.kernel.org, linux-arm-kernel@lists.infradead.org,
	Vincent Donnefort <vdonnefort@gmail.com>,
	<stable@vger.kernel.org>
To: Simon Guinot <simon.guinot@sequanux.org>
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <1435673149-12599-4-git-send-email-simon.guinot@sequanux.org>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dear Simon Guinot,

On Tue, 30 Jun 2015 16:05:49 +0200, Simon Guinot wrote:
> The Ethernet controller found in the Armada 370, 380 and 385 SoCs don't
> support TCP/IP checksumming with frame sizes larger than 1600 bytes.
> 
> This patch fixes the issue by disabling the features NETIF_F_IP_CSUM and
> NETIF_F_TSO for the Armada 370 and compatibles SoCs when the MTU is set
> to a value greater than 1600 bytes.
> 
> Signed-off-by: Simon Guinot <simon.guinot@sequanux.org>
> Fixes: c5aff18204da ("net: mvneta: driver for Marvell Armada 370/XP network unit")
> Cc: <stable@vger.kernel.org> # v3.8+

The title of this patch should be:

	net: mvneta: disable IP checksum with jumbo frames for Armada 370

because it is touching the network driver, and not the mvebu ARM core code.

Thanks,

Thomas
-- 
Thomas Petazzoni, CTO, Free Electrons
Embedded Linux, Kernel and Android engineering
http://free-electrons.com
