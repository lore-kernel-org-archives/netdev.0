From: Jeff Garzik <jgarzik@pobox.com>
Subject: Re: [PATCH v2] fs_enet: Fix a memory leak in fs_enet_mdio_probe
Date: Tue, 06 May 2008 12:23:18 -0400
Message-ID: <482085F6.5050004@pobox.com>
References: <20080502184241.GA7527@loki.buserror.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, akpm@linux-foundation.org,
	Daniel Marjamki <danielm77@spray.se>
To: Scott Wood <scottwood@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:41410 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751154AbYEFQXV (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 May 2008 12:23:21 -0400
In-Reply-To: <20080502184241.GA7527@loki.buserror.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Scott Wood wrote:
> There are more memory leaks in the !PPC_CPM_NEW_BINDING case, but that code
> will disappear soon along with arch/ppc.
> 
> Reported by Daniel Marjamki <danielm77@spray.se> at
> http://bugzilla.kernel.org/show_bug.cgi?id=10591
> 
> Signed-off-by: Scott Wood <scottwood@freescale.com>
> ---
>  drivers/net/fs_enet/mii-fec.c |    3 ++-
>  1 files changed, 2 insertions(+), 1 deletions(-)
> 

applied


