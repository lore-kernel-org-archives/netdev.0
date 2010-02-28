From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ethtool: do not set some flags, if others failed
Date: Sun, 28 Feb 2010 01:40:47 -0800 (PST)
Message-ID: <20100228.014047.212690802.davem@davemloft.net>
References: <20100227074338.GA17322@havoc.gtf.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: jeff@garzik.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41787
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1031664Ab0B1Jk2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 28 Feb 2010 04:40:28 -0500
In-Reply-To: <20100227074338.GA17322@havoc.gtf.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jeff Garzik <jeff@garzik.org>
Date: Sat, 27 Feb 2010 02:43:38 -0500

> 
> NETIF_F_NTUPLE flag setting introduced a bug:  non-ntuple flags
> like LRO may be successfully set, before ioctl(2) returns failure
> to userspace.
> 
> The set-flags operation should be all-or-none, rather than leaving
> things in an inconsistent state prior to reporting failure to
> userspace.
> 
> Signed-off-by: Jeff Garzik <jgarzik@redhat.com>

Applied, thanks Jeff.
