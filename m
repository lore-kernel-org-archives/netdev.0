From: Kumar Gala <galak@kernel.crashing.org>
Subject: Re: [PATCH 2/2] Rename get_property to of_get_property: drivers/net
Date: Wed, 2 May 2007 09:15:36 -0500
Message-ID: <3802D7AD-67EC-4FA2-B361-A388AFCB0B94@kernel.crashing.org>
References: <20070427145508.9c5641a2.sfr@canb.auug.org.au>
	<4633689E.50900@garzik.org>
	<20070429114446.31f40a30.sfr@canb.auug.org.au>
	<20070428.204754.62343452.davem@davemloft.net>
Mime-Version: 1.0 (Apple Message framework v752.2)
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: sfr@canb.auug.org.au, jeff@garzik.org, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org, paulus@samba.org, akpm@linux-foundation.org
To: David Miller <davem@davemloft.net>
Return-path: <linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org>
In-Reply-To: <20070428.204754.62343452.davem@davemloft.net>
List-Unsubscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=unsubscribe>
List-Archive: <http://ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@ozlabs.org?subject=help>
List-Subscribe: <https://ozlabs.org/mailman/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
Errors-To: linuxppc-dev-bounces+glppd-linuxppc64-dev=m.gmane.org@ozlabs.org
List-Id: netdev.vger.kernel.org


On Apr 28, 2007, at 10:47 PM, David Miller wrote:

> From: Stephen Rothwell <sfr@canb.auug.org.au>
> Date: Sun, 29 Apr 2007 11:44:46 +1000
>
>> So can I take this as a future OK for architecture specific network
>> drivers changes to go through the architecture trees (cc'd to you)?
>
> It's been my experience that if I'm just working through some
> platform or bus specific API changes, people like Jeff tend to
> not mind if it goes via ARCH trees and the like.

Is this acceptable?   Just want to make sure before I ask Paul to  
pull some changes that touches the following drivers:

drivers/net/fs_enet/mac-scc.c           |    2 +-
drivers/net/ucc_geth.c                  |   30 ++++----
drivers/serial/cpm_uart/cpm_uart_cpm1.c |    4 +-
drivers/serial/cpm_uart/cpm_uart_cpm2.c |    4 +-

But is related to an arch API cleanup.

- k
