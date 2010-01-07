From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] dmfe/tulip: Let dmfe handle DM910x except for SPARC
 on-board chips
Date: Thu, 07 Jan 2010 01:06:51 -0800 (PST)
Message-ID: <20100107.010651.18296756.davem@davemloft.net>
References: <1262660588.26813.24.camel@localhost>
	<20100105165817.GA13015@lackof.org>
	<20100107.005125.202622527.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ben@decadent.org.uk, brandon@ifup.org, grundler@google.com,
	tobias@ringis.se, kyle@mcmartin.ca, netdev@vger.kernel.org
To: grundler@parisc-linux.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41048
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755821Ab0AGJGn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 7 Jan 2010 04:06:43 -0500
In-Reply-To: <20100107.005125.202622527.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Thu, 07 Jan 2010 00:51:25 -0800 (PST)

> From: Grant Grundler <grundler@parisc-linux.org>
> Date: Tue, 5 Jan 2010 09:58:17 -0700
> 
>> On Tue, Jan 05, 2010 at 03:03:08AM +0000, Ben Hutchings wrote:
>>> The Davicom DM9100 and DM9102 chips are used on the motherboards of
>>> some SPARC systems (supported by the tulip driver) and also in PCI
>>> expansion cards (supported by the dmfe driver).  There is no
>>> difference in the PCI device ids for the two different configurations,
>>> so these drivers both claim the device ids.  However, it is possible
>>> to distinguish the two configurations by the presence of Open Firmware
>>> properties for them, so we do that.
>>> 
>>> Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
>> 
>> Signed-off-by: Grant Grundler <grundler@parisc-linux.org>
> 
> Applied, thanks everyone.

Sorry, had to revert, doesn't build:

  CHK     include/linux/version.h
  CHK     include/linux/utsrelease.h
  SYMLINK include/asm -> include/asm-sparc
  CALL    scripts/checksyscalls.sh
  CC [M]  drivers/net/tulip/dmfe.o
drivers/net/tulip/dmfe.c: In function 'dmfe_init_one':
drivers/net/tulip/dmfe.c:386: warning: suggest parentheses around && within ||
drivers/net/tulip/dmfe.c:389: error: implicit declaration of function 'of_get_property'
make[1]: *** [drivers/net/tulip/dmfe.o] Error 1
make: *** [drivers/net/tulip/dmfe.o] Error 2

Please fix this up and resubmit, thanks.
