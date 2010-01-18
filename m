From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: Regression: Wake on LAN doesn't work in sky2 with
 2.6.33-rc4-git2
Date: Mon, 18 Jan 2010 14:43:40 -0800
Message-ID: <20100118144340.100c9544@nehalam>
References: <20100115091053.GA5477@mac.home>
	<201001180136.45823.rjw@sisk.pl>
	<20100118083757.GA2619@mac.home>
	<201001182234.55113.rjw@sisk.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Tino Keitel <tino.keitel@tikei.de>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:53558 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754907Ab0ARWnv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 18 Jan 2010 17:43:51 -0500
In-Reply-To: <201001182234.55113.rjw@sisk.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 18 Jan 2010 22:34:55 +0100
"Rafael J. Wysocki" <rjw@sisk.pl> wrote:

> On Monday 18 January 2010, Tino Keitel wrote:
> > Hi,
> > 
> > reverting this commit fixes WoL for me:
> > 
> > commit 166a0fd4c788ec7f10ca8194ec6d526afa12db75
> > Author: stephen hemminger <shemminger@vyatta.com>
> > Date:   Mon Dec 14 08:50:12 2009 +0000
> > 
> >     sky2: leave PCI config space writeable
> >     
> >     Since power management is done by PCI subsystem as well as driver,
> >     don't toggle the bit that disables PCI register writes.
> >     
> >     Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
> >     Acked-by: Rafael J. Wysocki <rjw@sisk.pl>
> >     Signed-off-by: David S. Miller <davem@davemloft.net>
> 
> Hmm, this is kind of interesting.
> 
> Perhaps we clear the WoL setting somewhere we shouldn't, but the
> "disable PCI register writes" bit prevents this from actually happening?
> 
> Rafael

How about getting a register dump of pci config space with
good/bad version?

-- 
