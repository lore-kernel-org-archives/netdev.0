From: Richard Hobbs <r.w.hobbs@durham.ac.uk>
Subject: [PATCH 4 2.4.27] pcnet32: Add HomePNA parameter for 79C978.
Date: Fri, 4 Feb 2005 00:42:07 +0000 (UTC)
Message-ID: <loom.20050204T011847-673@post.gmane.org>
References: <d50018af05020314451010c5eb@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


I am trying to set up a hybrid network, part wired, part wireless and part
homePNA (the building has some very thick walls and remote computers that can be
reached by existing telephone wires). I am using Fedora core 3 with the 2.6.10
kernel.  I have  checked the pcnet32.c code and the patch 4 2.4.27 appears to be
there. 

I load the pcnet32 module using:
modprobe -v pcnet32 homepna=1

I get reply:
insmod /lib/modules/2.6.10-1.741_FC3/kernel/drivers/net/pcnet32.ko homepna=1

Looks good.

I then try to configure the network through the systems settings interface:
eth0 is a e100 ethernet to my router/modem that is OK.
Disconnecting eth0 to avoid any conflicts.

eth1 should be the AMD79c978 card. Connecting with the telephone wire

I set eth1 as an ethernet (I don't see an option for phoneline network)
I have tried DHCP get the response on activating the network:
Determining IP information for eth1 failed; no link present. Check cable.

I have tried a static IP address, card activates but no device is detected at
the modem/router.

If I unload the module and reload without the homepna option, the card works
fine with a standard ethernet cable.

Any suggestions please.

Thanks
Richard Hobbs
