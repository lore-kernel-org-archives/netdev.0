From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Cleanup the IPv6 addresses printing in /proc files
Date: Tue, 23 Oct 2007 21:10:45 -0700 (PDT)
Message-ID: <20071023.211045.23014439.davem@davemloft.net>
References: <471E2342.8090907@openvz.org>
	<20071023.204350.59654390.davem@davemloft.net>
	<1193198641.11845.49.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: xemul@openvz.org, netdev@vger.kernel.org, devel@openvz.org
To: joe@perches.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35611
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750836AbXJXELA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 24 Oct 2007 00:11:00 -0400
In-Reply-To: <1193198641.11845.49.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Joe Perches <joe@perches.com>
Date: Tue, 23 Oct 2007 21:04:01 -0700

> On Tue, 2007-10-23 at 20:43 -0700, David Miller wrote:
> > From: Pavel Emelyanov <xemul@openvz.org>
> > Date: Tue, 23 Oct 2007 20:37:22 +0400
> > > The /proc/net udp6, tcp6 and raw6 files print the IPs of
> > > the connection ends. Make a NIP6Lxxx macros (L stands for
> > > "long") for making the printing code look nicer.
> > > Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
> > Applied, thanks.
> 
> Why aren't these addresses converted with ntohl?

The reason is immaterial because whatever the kernel is doing
now we have to keep doing because applications parsing these
/proc files expect things to be how they are.

We'll break things if we change it.
