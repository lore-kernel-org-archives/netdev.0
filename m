From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] tulip: Fix for MTU problems with 802.1q tagged frames
Date: Fri, 13 Mar 2009 15:43:49 -0700 (PDT)
Message-ID: <20090313.154349.203057278.davem@davemloft.net>
References: <1236248494-1599-1-git-send-email-ivecera@redhat.com>
	<20090306181322.GA3616@colo.lackof.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ivecera@redhat.com, netdev@vger.kernel.org, kyle@mcmartin.ca,
	szpajder@staszic.waw.pl
To: grundler@parisc-linux.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:55017
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751588AbZCMWoD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Mar 2009 18:44:03 -0400
In-Reply-To: <20090306181322.GA3616@colo.lackof.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Grant Grundler <grundler@parisc-linux.org>
Date: Fri, 6 Mar 2009 11:13:22 -0700

> On Thu, Mar 05, 2009 at 11:21:34AM +0100, Ivan Vecera wrote:
> > The original patch was submitted last year but wasn't discussed or applied
> > because of missing maintainer's CCs. I only fixed some formatting errors,
> > but as I saw tulip is very badly formatted and needs further work.
> > 
> > Original description:
> > This patch fixes MTU problem, which occurs when using 802.1q VLANs. We
> > should allow receiving frames of up to 1518 bytes in length, instead of
> > 1514.
> > 
> > Based on patch written by Ben McKeegan for 2.4.x kernels. It is archived
> > at http://www.candelatech.com/~greear/vlan/howto.html#tulip
> > I've adjusted a few things to make it apply on 2.6.x kernels.
> > 
> > Tested on D-Link DFE-570TX quad-fastethernet card.
> > 
> > Signed-off-by: Tomasz Lemiech <szpajder@staszic.waw.pl>
> > Signed-off-by: Ivan Vecera <ivecera@redhat.com>
> 
> Acked-by: Grant Grundler <grundler@parisc-linux.org>

Applied to net-next-2.6, thanks everyone.
