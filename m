From: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>
Subject: Re: [PATCH v4 3/3] net: mvneta: disable IP checksum with jumbo
 frames for Armada 370
Date: Tue, 30 Jun 2015 16:26:19 +0200
Message-ID: <20150630162619.7b7cd078@free-electrons.com>
References: <1435674022-13295-1-git-send-email-simon.guinot@sequanux.org>
	<1435674022-13295-4-git-send-email-simon.guinot@sequanux.org>
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
Return-path: <netdev-owner@vger.kernel.org>
Received: from down.free-electrons.com ([37.187.137.238]:46880 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752380AbbF3O0W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Jun 2015 10:26:22 -0400
In-Reply-To: <1435674022-13295-4-git-send-email-simon.guinot@sequanux.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear Simon Guinot,

On Tue, 30 Jun 2015 16:20:22 +0200, Simon Guinot wrote:
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
> ---
>  drivers/net/ethernet/marvell/mvneta.c | 26 +++++++++++++++++++++++++-
>  1 file changed, 25 insertions(+), 1 deletion(-)

Acked-by: Thomas Petazzoni <thomas.petazzoni@free-electrons.com>

Thanks,

Thomas
-- 
Thomas Petazzoni, CTO, Free Electrons
Embedded Linux, Kernel and Android engineering
http://free-electrons.com
