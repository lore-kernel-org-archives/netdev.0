From: Kyle McMartin <kyle@infradead.org>
Subject: Re: [PATCH] tulip: Fix for MTU problems with 802.1q tagged frames
Date: Sun, 8 Mar 2009 15:53:17 -0400
Message-ID: <20090308195316.GA11260@bombadil.infradead.org>
References: <1236248494-1599-1-git-send-email-ivecera@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, grundler@parisc-linux.org,
	kyle@mcmartin.ca, Tomasz Lemiech <szpajder@staszic.waw.pl>
To: Ivan Vecera <ivecera@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bombadil.infradead.org ([18.85.46.34]:33661 "EHLO
	bombadil.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753294AbZCHTxX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Mar 2009 15:53:23 -0400
Content-Disposition: inline
In-Reply-To: <1236248494-1599-1-git-send-email-ivecera@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 05, 2009 at 11:21:34AM +0100, Ivan Vecera wrote:
> The original patch was submitted last year but wasn't discussed or applied
> because of missing maintainer's CCs. I only fixed some formatting errors,
> but as I saw tulip is very badly formatted and needs further work.
> 
> Original description:
> This patch fixes MTU problem, which occurs when using 802.1q VLANs. We
> should allow receiving frames of up to 1518 bytes in length, instead of
> 1514.
> 
> Based on patch written by Ben McKeegan for 2.4.x kernels. It is archived
> at http://www.candelatech.com/~greear/vlan/howto.html#tulip
> I've adjusted a few things to make it apply on 2.6.x kernels.
> 
> Tested on D-Link DFE-570TX quad-fastethernet card.
> 
> Signed-off-by: Tomasz Lemiech <szpajder@staszic.waw.pl>
> Signed-off-by: Ivan Vecera <ivecera@redhat.com>
>

Feel free to add Acked-by or Tested-by: Kyle McMartin
<kyle@mcmartin.ca>, it doesn't cause any regressions on any of my tulip
cards.

regards, Kyle
