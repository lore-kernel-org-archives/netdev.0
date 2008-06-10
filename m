From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: Pull request for mv643xx_eth 'for-2.6.27' branch
Date: Wed, 11 Jun 2008 00:25:28 +0200
Message-ID: <20080610222528.GA8421@xi.wantstofly.org>
References: <20080606113747.GA7778@xi.wantstofly.org> <484EFCF3.4020703@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: dale@farnsworth.org, netdev@vger.kernel.org
To: Jeff Garzik <jeff@garzik.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([83.160.184.112]:56539 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755035AbYFJW0J (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jun 2008 18:26:09 -0400
Content-Disposition: inline
In-Reply-To: <484EFCF3.4020703@garzik.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 10, 2008 at 06:15:15PM -0400, Jeff Garzik wrote:

> >Please pull the following mv643xx_eth patches for 2.6.27.  (They
> >were all ACKed by Dale, and I've agreed to take over mv643xx_eth
> >maintainership from him.)
> >
> >
> >thanks,
> >Lennert
> >
> >
> >
> >The following changes since commit 
> >39b945a37bac2b692773a470890c8ba301485b15:
> >  Linus Torvalds (1):
> >        Merge master.kernel.org:/home/rmk/linux-2.6-arm
> >
> >are available in the git repository at:
> >
> >  git://git.marvell.com/mv643xx_eth.git for-2.6.27
> >
> >Dale Farnsworth (1):
> >      mv643xx_eth: new maintainer
> >
> >Lennert Buytenhek (38):
> >      mv643xx_eth: reverse topological sort of functions
> >      mv643xx_eth: trim unnecessary includes
> >      mv643xx_eth: shorten reg names
> >      mv643xx_eth: get rid of individual port config register bit defines
> >      mv643xx_eth: get rid of individual port config extend register bit 
> >      defines
> >      mv643xx_eth: delete unused SDMA config register bit defines
> >      mv643xx_eth: delete unused port serial control register bit defines
> >      mv643xx_eth: nuke port status register bit defines
> >      mv643xx_eth: remove unused DESC_SIZE define
> >      mv643xx_eth: clarify irq masking and unmasking
> >      mv643xx_eth: move PHY wait defines into callers
> >      mv643xx_eth: get rid of RX_BUF_OFFSET
> >      mv643xx_eth: move MIB offset defines into their only user
> >      mv643xx_eth: remove port serial status register bit defines
> >      mv643xx_eth: clean up rx/tx descriptor field defines
> >      mv643xx_eth: get rid of ETH_/ethernet_/eth_ prefixes
> >      mv643xx_eth: use 'mv643xx_eth_' prefix consistently
> >      mv643xx_eth: kill superfluous comments
> >      mv643xx_eth: kill ->rx_resource_err
> >      mv643xx_eth: get rid of hungarian variable naming
> >      mv643xx_eth: move port_receive() into its only caller
> >      mv643xx_eth: move rx_return_buff() into its only caller
> >      mv643xx_eth: kill FUNC_RET_STATUS/pkt_info
> >      mv643xx_eth: kill private unused instance of struct net_device_stats
> >      mv643xx_eth: massively simplify multicast address crc8 computation
> >      mv643xx_eth: split out rx queue state
> >      mv643xx_eth: split out tx queue state
> >      mv643xx_eth: remove write-only interrupt coalescing variables
> >      mv643xx_eth: general cleanup
> >      mv643xx_eth: add tx rate control
> >      mv643xx_eth: allow multiple RX queues
> >      mv643xx_eth: allow multiple TX queues
> >      mv643xx_eth: work around TX hang hardware issue
> >      mv643xx_eth: detect extended rx coal register field
> >      mv643xx_eth: detect alternate TX BW control register location
> >      mv643xx_eth: be more agressive about RX refill
> >      mv643xx_eth: add PHY-less mode
> >      mv643xx_eth: update driver version and author fields
> 
> ignore my last email... is this current?  or is there more?

This is current and complete -- I don't have anything else queued
up at this point.
