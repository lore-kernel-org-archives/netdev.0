From: Kumar Gala <galak@kernel.crashing.org>
Subject: Re: [PATCH] ucc_geth: Change uec phy id to the same format as gianfar's
Date: Thu, 29 Jan 2009 12:42:38 -0600
Message-ID: <FD1B55B4-574B-4B77-889D-FD81D77DCA5E__8785.29935512251$1233254698$gmane$org@kernel.crashing.org>
References: <1233254342-8435-1-git-send-email-Haiying.Wang@freescale.com>
Mime-Version: 1.0 (Apple Message framework v929.2)
Content-Type: text/plain; charset=US-ASCII; format=flowed; delsp=yes
Content-Transfer-Encoding: 7bit
Cc: linuxppc-dev list <linuxppc-dev@ozlabs.org>,
	netdev@vger.kernel.org, Haiying Wang <Haiying.Wang@freescale.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:60462 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752295AbZA2Sm4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Jan 2009 13:42:56 -0500
In-Reply-To: <1233254342-8435-1-git-send-email-Haiying.Wang@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Jan 29, 2009, at 12:39 PM, Haiying Wang wrote:

> The commit b31a1d8b41513b96e9c7ec2f68c5734cef0b26a4 changes the  
> gianfar's phy id to
> the format like "mdio@xxxx:xx", but uec still uses the old format  
> like "xxxxxxxx:xx".
> For the board whose UEC uses gianfar-mdio like MPC8568MDS, the phy  
> can not be attached
> because of the incompatible phy id format. This patch changes uec's  
> phy id to the same
> format as gianfar's.
>
> Signed-off-by: Haiying Wang <Haiying.Wang@freescale.com>
> ---
> drivers/net/ucc_geth.c           |   20 ++++++++++++++++++--
> drivers/net/ucc_geth.h           |    2 ++
> drivers/net/ucc_geth_mii.c       |   12 +++++++++++-
> drivers/net/ucc_geth_mii.h       |    1 +
> 4 files changed, 32 insertions(+), 3 deletions(-)

David,

Can you look at this for 2.6.29.

- k
