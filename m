From: Ben McKeegan <ben@netservers.co.uk>
Subject: Re: [PATCH] tulip: Fix for MTU problems with 802.1q tagged frames
Date: Fri, 06 Mar 2009 12:48:38 +0000
Message-ID: <49B11BA6.7060103@netservers.co.uk>
References: <1236248494-1599-1-git-send-email-ivecera@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, grundler@parisc-linux.org,
	kyle@mcmartin.ca, Tomasz Lemiech <szpajder@staszic.waw.pl>
To: Ivan Vecera <ivecera@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.netservers.co.uk ([80.248.178.71]:35030 "EHLO
	mail.netservers.co.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750724AbZCFMuS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 6 Mar 2009 07:50:18 -0500
In-Reply-To: <1236248494-1599-1-git-send-email-ivecera@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ivan Vecera wrote:
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

Looks good.  FWIW:

Signed-off-by: Ben McKeegan <ben@netservers.co.uk>



