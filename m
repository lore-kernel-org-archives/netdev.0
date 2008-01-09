From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6.25 2/6][IPVS] Switch to using ctl_paths.
Date: Wed, 09 Jan 2008 00:30:58 -0800 (PST)
Message-ID: <20080109.003058.232200899.davem@davemloft.net>
References: <47839C30.2040402@openvz.org>
	<47839D93.8090406@openvz.org>
	<20080109024914.GG3403@verge.net.au>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xemul@openvz.org, netdev@vger.kernel.org, devel@openvz.org
To: horms@verge.net.au
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57621
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750940AbYAIIa7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jan 2008 03:30:59 -0500
In-Reply-To: <20080109024914.GG3403@verge.net.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Horman <horms@verge.net.au>
Date: Wed, 9 Jan 2008 11:49:16 +0900

> On Tue, Jan 08, 2008 at 06:58:11PM +0300, Pavel Emelyanov wrote:
> > The feature of ipvs ctls is that the net/ipv4/vs path
> > is common for core ipvs ctls and for two schedulers,
> > so I make it exported and re-use it in modules.
> > 
> > Two other .c files required linux/sysctl.h to make the
> > extern declaration of this path compile well.
> > 
> > Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
> 
> Thanks, this looks good to me and I've confirmed that
> the same entires with the same permissions exist under
> /proc/sys/net/ipv4/vs before and after the change.
> 
> Acked-by: Simon Horman <horms@verge.net.au>

Applied, thanks everyone.
