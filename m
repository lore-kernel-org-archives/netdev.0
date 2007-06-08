From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2/2] fix several unaligned kernel accesses in the CIPSO
 engine
Date: Thu, 07 Jun 2007 18:38:23 -0700 (PDT)
Message-ID: <20070607.183823.72710741.davem@davemloft.net>
References: <20070607153226.524778346@hp.com>
	<20070607153610.888828690@hp.com>
	<Line.LNX.4.64.0706072120050.10435@d.namei>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: paul.moore@hp.com, netdev@vger.kernel.org, selinux@tycho.nsa.gov
To: jmorris@namei.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37826
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S935554AbXFHBiH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jun 2007 21:38:07 -0400
In-Reply-To: <Line.LNX.4.64.0706072120050.10435@d.namei>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: James Morris <jmorris@namei.org>
Date: Thu, 7 Jun 2007 21:20:20 -0400 (EDT)

> On Thu, 7 Jun 2007, Paul Moore wrote:
> 
> > IPv4 options are not very well aligned within the packet and the format of a
> > CIPSO option is even worse.  The result is that the CIPSO engine in the kernel
> > does a few unaligned accesses when parsing and validating incoming packets with
> > CIPSO options attached which generate error messages on certain alignment
> > sensitive platforms.  This patch fixes this by marking these unaligned accesses
> > with the get_unaliagned() macro.
> > 
> > Signed-off-by: Paul Moore <paul.moore@hp.com>
> 
> 
> Acked-by: James Morris <jmorris@namei.org>

Also applied, thanks.
