From: David Miller <davem@davemloft.net>
Subject: Re: [2.6 patch] net/sctp/: cleanups
Date: Mon, 18 Sep 2006 00:40:51 -0700 (PDT)
Message-ID: <20060918.004051.49243272.davem@davemloft.net>
References: <20060905215721.GM9173@stusta.de>
	<1157499861.3728.7.camel@w-sridhar2.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bunk@stusta.de, lksctp-developers@lists.sourceforge.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	dwmw2@infradead.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:40638
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1751572AbWIRHkx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Sep 2006 03:40:53 -0400
To: sri@us.ibm.com
In-Reply-To: <1157499861.3728.7.camel@w-sridhar2.beaverton.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Sridhar Samudrala <sri@us.ibm.com>
Date: Tue, 05 Sep 2006 16:44:21 -0700

> On Tue, 2006-09-05 at 23:57 +0200, Adrian Bunk wrote:
> > This patch contains the following cleanups:
> > - make the following needlessly global function static:
> >   - socket.c: sctp_apply_peer_addr_params()
> > - add proper prototypes for the several global functions in
> >   include/net/sctp/sctp.h
> > 
> > Note that this fixes wrong prototypes for the following functions:
> > - sctp_snmp_proc_exit()
> > - sctp_eps_proc_exit()
> > - sctp_assocs_proc_exit()
> > 
> > The latter was spotted by the GNU C compiler and reported
> > by David Woodhouse.
> > 
> > Signed-off-by: Adrian Bunk <bunk@stusta.de>
> 
> Acked-by: Sridhar Samudrala <sri@us.ibm.com>

Applied, thanks.
