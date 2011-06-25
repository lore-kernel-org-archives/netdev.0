From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [RFC 18/72] ehea/ibm*: Move the IBM drivers
Date: Sat, 25 Jun 2011 17:04:22 +0200
Message-ID: <201106251704.22561.arnd@arndb.de>
References: <1309010363-22750-1-git-send-email-jeffrey.t.kirsher@intel.com> <1309010363-22750-19-git-send-email-jeffrey.t.kirsher@intel.com> <4E05F320.1080202@hartkopp.net>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>, davem@davemloft.net,
	netdev@vger.kernel.org, Christoph Raisch <raisch@de.ibm.com>,
	Alfred Arnold <alfred.arnold@lancom.de>,
	Santiago Leon <santil@linux.vnet.ibm.com>,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>
To: Oliver Hartkopp <socketcan@hartkopp.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.17.9]:53328 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751348Ab1FYPEe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Jun 2011 11:04:34 -0400
In-Reply-To: <4E05F320.1080202@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Saturday 25 June 2011, Oliver Hartkopp wrote:
> >  drivers/net/{ => ethernet/ibm}/ibm_newemac/Kconfig |    2 +-
> >  .../net/{ => ethernet/ibm}/ibm_newemac/Makefile    |    0
> >  drivers/net/{ => ethernet/ibm}/ibm_newemac/core.c  |    0
> >  drivers/net/{ => ethernet/ibm}/ibm_newemac/core.h  |    0
> >  drivers/net/{ => ethernet/ibm}/ibm_newemac/debug.c |    0
> >  drivers/net/{ => ethernet/ibm}/ibm_newemac/debug.h |    0
> >  drivers/net/{ => ethernet/ibm}/ibm_newemac/emac.h  |    0
> >  drivers/net/{ => ethernet/ibm}/ibm_newemac/mal.c   |    0
> >  drivers/net/{ => ethernet/ibm}/ibm_newemac/mal.h   |    0
> >  drivers/net/{ => ethernet/ibm}/ibm_newemac/phy.c   |    0
> >  drivers/net/{ => ethernet/ibm}/ibm_newemac/phy.h   |    0
> >  drivers/net/{ => ethernet/ibm}/ibm_newemac/rgmii.c |    0
> >  drivers/net/{ => ethernet/ibm}/ibm_newemac/rgmii.h |    0
> >  drivers/net/{ => ethernet/ibm}/ibm_newemac/tah.c   |    0
> >  drivers/net/{ => ethernet/ibm}/ibm_newemac/tah.h   |    0
> >  drivers/net/{ => ethernet/ibm}/ibm_newemac/zmii.c  |    0
> >  drivers/net/{ => ethernet/ibm}/ibm_newemac/zmii.h  |    0
> 
> s/ibm_newemac/newemac/
> 
> as it is already inside a directory called ibm?
> 

You can probably rename to just emac now, since the "old" emac driver
has been gone for some time.

The "new" part of the name does not refer to the hardware, just to
the driver.

	Arnd
