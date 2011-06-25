From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [RFC 34/72] skge/sky2: Move the SysKonnect Ethernet drivers
Date: Sat, 25 Jun 2011 09:26:53 -0700
Message-ID: <20110625092653.627fcc89@nehalam.ftrdhcpuser.net>
References: <1309010363-22750-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1309010363-22750-35-git-send-email-jeffrey.t.kirsher@intel.com>
	<201106251649.13877.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, davem@davemloft.net,
	netdev@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:41800 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751303Ab1FYQ1F (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Jun 2011 12:27:05 -0400
In-Reply-To: <201106251649.13877.arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 25 Jun 2011 16:49:13 +0200
Arnd Bergmann <arnd@arndb.de> wrote:

> On Saturday 25 June 2011, Jeff Kirsher wrote:
> > Move the SysKonnect Ethernet drivers into drivers/net/ethernet/syskonnect/
> > and make the necessary Kconfig and Makefile changes.
> > 
> > CC: Stephen Hemminger <shemminger@linux-foundation.org>
> > Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
> > ---
> >  MAINTAINERS                                  |    3 +-
> >  drivers/net/Kconfig                          |   58 --------------------
> >  drivers/net/Makefile                         |    2 -
> >  drivers/net/ethernet/Kconfig                 |    1 +
> >  drivers/net/ethernet/Makefile                |    1 +
> >  drivers/net/ethernet/syskonnect/Kconfig      |   74 ++++++++++++++++++++++++++
> >  drivers/net/ethernet/syskonnect/Makefile     |    6 ++
> >  drivers/net/{ => ethernet/syskonnect}/skge.c |    0
> >  drivers/net/{ => ethernet/syskonnect}/skge.h |    0
> >  drivers/net/{ => ethernet/syskonnect}/sky2.c |    0
> >  drivers/net/{ => ethernet/syskonnect}/sky2.h |    0
> 
> Shouldn't these live together with the other Marvell drivers?

yes put them under Marvell.
