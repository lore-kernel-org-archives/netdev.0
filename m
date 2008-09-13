From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH 1/3] ibm_newemac: Allow the "no flow control" EMAC feature
 to work
Date: Sat, 13 Sep 2008 15:40:55 -0400
Message-ID: <48CC1747.40408@garzik.org>
References: <cover.1220877899.git.jwboyer@linux.vnet.ibm.com> <62e3d970a3bcb8158308bb645f99c75a41d177ff.1220877899.git.jwboyer@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: benh@kernel.crashing.org, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org
To: Josh Boyer <jwboyer@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:36514 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752660AbYIMTlB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 13 Sep 2008 15:41:01 -0400
In-Reply-To: <62e3d970a3bcb8158308bb645f99c75a41d177ff.1220877899.git.jwboyer@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Josh Boyer wrote:
> Some PowerPC 40x chips have errata that force us not to use the integrated
> flow control.  We have the feature defined, but it currently can't be used
> because it is never added to EMAC_FTRS_POSSIBLE.
> 
> This adds a Kconfig option for affected platforms to select and puts the
> feature in the EMAC_FTRS_POSSIBLE list.  This is set for PowerPC 405EZ
> platforms as well.
> 
> Signed-off-by: Josh Boyer <jwboyer@linux.vnet.ibm.com>
> ---
>  drivers/net/ibm_newemac/Kconfig |    4 ++++
>  drivers/net/ibm_newemac/core.c  |    2 ++
>  drivers/net/ibm_newemac/core.h  |    3 +++
>  3 files changed, 9 insertions(+), 0 deletions(-)

ACK patches 1-3


