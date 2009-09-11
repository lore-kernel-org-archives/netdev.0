From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [net-next PATCH] etherdevice.h: random_ether_addr update
Date: Fri, 11 Sep 2009 14:15:54 -0700
Message-ID: <20090911141554.0072d365@nehalam>
References: <20090911014757.19631.66570.stgit@localhost.localdomain>
	<20090910190703.25d14533@nehalam>
	<1252638163.4355.35.camel@Joe-Laptop.home>
	<20090911.121542.45333246.davem@davemloft.net>
	<1252700442.15292.62.camel@Joe-Laptop.home>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, jeffrey.t.kirsher@intel.com,
	netdev@vger.kernel.org, gospo@redhat.com, gregory.v.rose@intel.com,
	donald.c.skidmore@intel.com
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:52797 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756854AbZIKVP5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Sep 2009 17:15:57 -0400
In-Reply-To: <1252700442.15292.62.camel@Joe-Laptop.home>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 11 Sep 2009 13:20:42 -0700
Joe Perches <joe@perches.com> wrote:

> On Fri, 2009-09-11 at 12:15 -0700, David Miller wrote:
> > From: Joe Perches <joe@perches.com>
> > Date: Thu, 10 Sep 2009 20:02:43 -0700
> > > On Thu, 2009-09-10 at 19:07 -0700, Stephen Hemminger wrote:
> > >> On Thu, 10 Sep 2009 18:48:27 -0700
> > >> Jeff Kirsher <jeffrey.t.kirsher@intel.com> wrote:
> > >> > From: Gregory Rose <gregory.v.rose@intel.com>
> > >> > This patch changes the default VF MAC address generation to use an Intel
> > >> > Organizational Unit Identifier (OUI), instead of a fully randomized
> > >> > Ethernet address.  This is to help prevent accidental MAC address
> > >> > collisions.
> > > I think this not a very good idea.
> > I also completely agree that this patch is not a wise move.
> 
> Perhaps this?
> 
> random_ether_address should not assign an "0x02" leading octet.
> 
> "02" has the local assignment bit set,
> but is actually a value assigned via OUI.
> 
> Do not use get_random_bytes to avoid drawing down entropy pool.
> 

Getting 6 bytes once is not going to be enough of a problem
to drain the pool. I prefer not to weaken the randomness here.


-- 
