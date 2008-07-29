From: Jeff Garzik <jeff@garzik.org>
Subject: Re: mv643xx_eth: pull request for for-2.6.27 branch
Date: Tue, 29 Jul 2008 18:23:25 -0400
Message-ID: <488F985D.1050203@garzik.org>
References: <20080724052140.GA19392@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: dale@farnsworth.org, netdev@vger.kernel.org, nico@cam.org
To: Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:57184 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751372AbYG2WXb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 29 Jul 2008 18:23:31 -0400
In-Reply-To: <20080724052140.GA19392@xi.wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Lennert Buytenhek wrote:
> This patch series consists of the patches posted so far that should be
> good to go in for 2.6.27 and should be the last batch before -rc1: the
> three interface TX hang fixes, revamping the link up/down handling to
> fix a couple more PHYless cases (which as a side-effect will require
> specifying speed/duplex explicitly in the platform data) and to no
> longer do MII accesses from interrupt context, enabling TX checksumming
> on VLANed packets, and some more assorted minor changes.
> 
> 
> The following changes since commit c010b2f76c3032e48097a6eef291d8593d5d79a6:
>   Linus Torvalds (1):
>         Merge git://git.kernel.org/.../davem/net-2.6
> 
> are available in the git repository at:
> 
>   git://git.marvell.com/mv643xx_eth.git for-2.6.27
> 
> Lennert Buytenhek (12):
>       mv643xx_eth: fix TX hang erratum workaround
>       mv643xx_eth: prevent breakage when link goes down during transmit
>       mv643xx_eth: fix transmit-reclaim-in-napi-poll
>       mv643xx_eth: don't fiddle with maximum receive packet size setting
>       mv643xx_eth: also check TX_IN_PROGRESS when disabling transmit path
>       mv643xx_eth: use longer DMA bursts
>       mv643xx_eth: use symbolic MII register addresses and values
>       mv643xx_eth: print driver version on init
>       mv643xx_eth: use auto phy polling for configuring (R)(G)MII interface
>       mv643xx_eth: print message on link status change
>       mv643xx_eth: enable hardware TX checksumming with vlan tags
>       mv643xx_eth: bump version to 1.2
> 
>  arch/arm/mach-kirkwood/rd88f6281-setup.c     |    3 +
>  arch/arm/mach-orion5x/rd88f5181l-fxo-setup.c |    3 +
>  arch/arm/mach-orion5x/rd88f5181l-ge-setup.c  |    3 +
>  arch/arm/mach-orion5x/wnr854t-setup.c        |    3 +
>  arch/arm/mach-orion5x/wrt350n-v2-setup.c     |    3 +
>  drivers/net/mv643xx_eth.c                    |  358 +++++++++++++++++---------
>  6 files changed, 251 insertions(+), 122 deletions(-)

pulled


