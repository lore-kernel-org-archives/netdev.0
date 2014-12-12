From: Simon Horman <horms@verge.net.au>
Subject: Re: errors in alignment changes..
Date: Fri, 12 Dec 2014 13:30:10 +0900
Message-ID: <20141212043010.GC17790@verge.net.au>
References: <20141210.155203.1136471667049608187.davem@davemloft.net>
 <5488C447.5080906@cogentembedded.com>
 <20141210.204215.46146677361631214.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: sergei.shtylyov@cogentembedded.com,
	mitsuhiro.kimura.kc@renesas.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from kirsty.vergenet.net ([202.4.237.240]:33729 "EHLO
	kirsty.vergenet.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933985AbaLLEaN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Dec 2014 23:30:13 -0500
Content-Disposition: inline
In-Reply-To: <20141210.204215.46146677361631214.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 10, 2014 at 08:42:15PM -0500, David Miller wrote:
> From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
> Date: Thu, 11 Dec 2014 01:08:07 +0300
> 
> >    I guess we can just do:
> > 
> > 		rxdesc->addr = dma_map_single(...);
> 
> Best not to leave a potentially invalid DMA address in a
> receive descriptor the chip can potentially fetch and
> look at.
> 
> That's why I said to put it into a local variable and
> check for errors first.

Hi Dave,

this patch ending up in net is partially my fault.

Sergei, do you have time to address David's concerns in relation to this
patch? If not I would like to suggest reverting it for now.
