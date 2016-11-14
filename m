From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v7 03/10] dpaa_eth: add option to use one
 buffer pool set
Date: Mon, 14 Nov 2016 12:31:41 -0500 (EST)
Message-ID: <20161114.123141.575224690412855747.davem@davemloft.net>
References: <1478852407-27420-4-git-send-email-madalin.bucur@nxp.com>
        <20161113.124617.2176429700446266337.davem@davemloft.net>
        <AM4PR04MB16040D32960405FD16007950ECBC0@AM4PR04MB1604.eurprd04.prod.outlook.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@lists.ozlabs.org,
        linux-kernel@vger.kernel.org, oss@buserror.net,
        ppc@mindchasers.com, joe@perches.com, pebolle@tiscali.nl,
        joakim.tjernlund@infinera.com
To: madalin.bucur@nxp.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <AM4PR04MB16040D32960405FD16007950ECBC0@AM4PR04MB1604.eurprd04.prod.outlook.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Madalin-Cristian Bucur <madalin.bucur@nxp.com>
Date: Mon, 14 Nov 2016 10:25:13 +0000

> I've introduced this Kconfig option as a backwards compatible option, to
> be able to run comparative tests between the independent buffer pool setup
> and the previous common buffer pool setup. There are not so many reasons
> to use the same buffer pool besides "having the old setup", the memory
> saving is marginal, in all other aspects the separate buffer pools setup
> fares better.
> 
> I'll remove this patch from the next submission. Should anyone care for
> this I can add an entry to the feature backlog to add runtime support but
> it will be quite low in priority.

If it's a debugging feature then that's certainly how this should be
handled.
