From: Don Fry <brazilnut@us.ibm.com>
Subject: Re: [PATCH 4 2.4.27] pcnet32: Add HomePNA parameter for 79C978.
Date: Fri, 4 Feb 2005 10:45:31 -0800
Message-ID: <20050204184531.GA15595@us.ibm.com>
References: <d50018af05020314451010c5eb@mail.gmail.com> <loom.20050204T011847-673@post.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@oss.sgi.com
To: Richard Hobbs <r.w.hobbs@durham.ac.uk>
Content-Disposition: inline
In-Reply-To: <loom.20050204T011847-673@post.gmane.org>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Richard,

2.6.10 has the driver to support the 79c978 card in homepna mode.  I
have only used the card in a point-to-point configuration when in
homepna mode, because all I have is two cards (no modem/router).

When you bring up the card with homepna=1, if you look in
/var/log/messages it should indicate the speed at which the card is
operating.  In my system I see:

pcnet32: media set to 1Mbit mode.
pcnet32: PCnet/Home 79C978 at 0x252c00, 00 90 00 05 dd 27 assigned IRQ 201.
eth8: registered as PCnet/Home 79C978
pcnet32: 8 cards_found.

With the cards cabled together I see link detected using ethtool.

# ethtool eth8
Settings for eth8:
        Current message level: 0x00000007 (7)
        Link detected: yes

On Fri, Feb 04, 2005 at 12:42:07AM +0000, Richard Hobbs wrote:
> 
> I am trying to set up a hybrid network, part wired, part wireless and part
> homePNA (the building has some very thick walls and remote computers that can be
> reached by existing telephone wires). I am using Fedora core 3 with the 2.6.10
> kernel.  I have  checked the pcnet32.c code and the patch 4 2.4.27 appears to be
> there. 
> 
> I load the pcnet32 module using:
> modprobe -v pcnet32 homepna=1
> 
> I get reply:
> insmod /lib/modules/2.6.10-1.741_FC3/kernel/drivers/net/pcnet32.ko homepna=1
> 
> Looks good.
> 
> I then try to configure the network through the systems settings interface:
> eth0 is a e100 ethernet to my router/modem that is OK.
> Disconnecting eth0 to avoid any conflicts.
> 
> eth1 should be the AMD79c978 card. Connecting with the telephone wire
> 
> I set eth1 as an ethernet (I don't see an option for phoneline network)
> I have tried DHCP get the response on activating the network:
> Determining IP information for eth1 failed; no link present. Check cable.
> 
> I have tried a static IP address, card activates but no device is detected at
> the modem/router.
> 
> If I unload the module and reload without the homepna option, the card works
> fine with a standard ethernet cable.
> 
> Any suggestions please.
> 
> Thanks
> Richard Hobbs

-- 
Don Fry
brazilnut@us.ibm.com
