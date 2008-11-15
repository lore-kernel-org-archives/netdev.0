From: David Miller <davem@davemloft.net>
Subject: Re: [stable] [BUG] net: fix /proc/net/snmp as memory corruptor
Date: Fri, 14 Nov 2008 22:23:20 -0800 (PST)
Message-ID: <20081114.222320.193686818.davem@davemloft.net>
References: <491D07E0.9010903@cosmosbay.com>
	<20081115051015.GB26468@kroah.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: dada1@cosmosbay.com, stable@kernel.org, netdev@vger.kernel.org
To: greg@kroah.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:45884
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752113AbYKOGXV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 15 Nov 2008 01:23:21 -0500
In-Reply-To: <20081115051015.GB26468@kroah.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Greg KH <greg@kroah.com>
Date: Fri, 14 Nov 2008 21:10:15 -0800

> On Fri, Nov 14, 2008 at 06:08:48AM +0100, Eric Dumazet wrote:
> > Hello Greg
> > 
> > A patch was submited about /proc/net/snmp being a memory corruptor and not SMP safe
> > 
> > (commit b971e7ac834e9f4bda96d5a96ae9abccd01c1dd8)
> > 
> > These bugs are present on 2.6.26 & 2.6.27.
> 
> I looking at this, it doesn't seem to apply at all to the .27 tree.  If
> David doesn't object, care to backport it there and send it to
> stable@kernel.org?

No objection.
