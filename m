From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 2/2] Rename get_property to of_get_property: drivers/net
Date: Sat, 28 Apr 2007 11:30:38 -0400
Message-ID: <4633689E.50900@garzik.org>
References: <20070427145107.4f73e436.sfr@canb.auug.org.au> <20070427145508.9c5641a2.sfr@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: ppc-dev <linuxppc-dev@ozlabs.org>, netdev@vger.kernel.org
To: Stephen Rothwell <sfr@canb.auug.org.au>, paulus@samba.org,
	akpm@linux-foundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:52140 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1161512AbXD1Pay (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 28 Apr 2007 11:30:54 -0400
In-Reply-To: <20070427145508.9c5641a2.sfr@canb.auug.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Stephen Rothwell wrote:
> This is part of the consolidation of the OpenFirmware code ebtween
> PowerPC and Sparc.
> 
> Signed-off-by: Stephen Rothwell <sfr@canb.auug.org.au>
> ---
>  drivers/net/bmac.c           |    5 +++--
>  drivers/net/ehea/ehea_main.c |    6 +++---
>  drivers/net/mace.c           |    4 ++--
>  drivers/net/pasemi_mac.c     |    2 +-
>  drivers/net/spider_net.c     |    4 ++--
>  drivers/net/sungem.c         |    2 +-
>  drivers/net/sungem_phy.c     |    2 +-
>  drivers/net/ucc_geth.c       |   18 +++++++++---------
>  drivers/net/ucc_geth_mii.c   |    4 ++--
>  9 files changed, 24 insertions(+), 23 deletions(-)
> 
> Jeff,
> 
> This patch is based on a merge between Paulus' for-2.6.22 tree and your
> upstream tree.  As such it depends on changes in Paulus' tree to be
> merged first.  This patch was originally in Paulus' tree but has been
> reverted from there.

Sorry for your being a football here.

AFAICS, looking at the two patches, it seems clear they should go in via 
Paulus's tree.  There are clear dependencies, and it is clearly 
arch-specific code.

If anything, it sounds like I should drop a ucc_geth patch or two from 
my tree.  Is that the case?

	Jeff



