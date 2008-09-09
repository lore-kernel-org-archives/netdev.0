From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: Re: [PATCH 0/3 v2] ibm_newemac: Various fixes and additions for
	PPC405EZ
Date: Tue, 09 Sep 2008 17:11:23 +1000
Message-ID: <1220944283.4879.323.camel@pasglop>
References: <cover.1220877899.git.jwboyer@linux.vnet.ibm.com>
Reply-To: benh@kernel.crashing.org
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linuxppc-dev@ozlabs.org
To: Josh Boyer <jwboyer@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gate.crashing.org ([63.228.1.57]:49509 "EHLO gate.crashing.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753261AbYIIHTn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Sep 2008 03:19:43 -0400
In-Reply-To: <cover.1220877899.git.jwboyer@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2008-09-08 at 08:44 -0400, Josh Boyer wrote:
> The following patch series adds things needed to support the PowerPC 405EZ
> SoC.  I've incorporated the suggestions and fixes from the previous round
> of patches and barring any further comments these should be ready to go.

For some reason, I got this email but not the 3 following patch ones...

Cheers,
Ben.

> josh
> 
> Josh Boyer (3):
>   ibm_newemac: Allow the "no flow control" EMAC feature to work
>   ibm_newemac: Introduce mal_has_feature
>   ibm_newemac: MAL support for PowerPC 405EZ
> 
>  arch/powerpc/include/asm/dcr-regs.h |    7 ++++
>  drivers/net/ibm_newemac/Kconfig     |   12 +++++++
>  drivers/net/ibm_newemac/core.c      |    2 +
>  drivers/net/ibm_newemac/core.h      |    3 ++
>  drivers/net/ibm_newemac/mal.c       |   60 ++++++++++++++++++++++++++++++++---
>  drivers/net/ibm_newemac/mal.h       |   34 ++++++++++++++++++++
>  6 files changed, 113 insertions(+), 5 deletions(-)

