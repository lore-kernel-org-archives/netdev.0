From: "Andreas Herrmann" <AHERRMAN@de.ibm.com>
Subject: Re: [PATCH] new net device feature: shared-ipv6-cards
Date: Mon, 19 Aug 2002 11:57:11 +0200
Sender: owner-netdev@oss.sgi.com
Message-ID: <OFB130AE35.650BE060-ONC1256C1A.00366E92@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: ak@suse.de, kuznet@ms2.inr.ac.ru, netdev@oss.sgi.com,
   owner-netdev@oss.sgi.com, pekkas@netcore.fi
Return-path: <owner-netdev@oss.sgi.com>
To: "David S. Miller" <davem@redhat.com>
List-Id: netdev.vger.kernel.org

      "David S. Miller" <davem@redhat.com>
      08/19/02 10:11 AM

  >    From: "Andreas Herrmann" <AHERRMAN@de.ibm.com>
  >    Date: Mon, 19 Aug 2002 10:20:19 +0200

  >    The following changes are performed:

  >     o Documentation/Configure.help
  >       net/Config.in
  >            Configure option and help text for the new feature.

  > No config option please.  If device driver indicates it wants this
  > behavior with a flag bit, no need to duplicate this logic.
  > It is likely that it will not be just z-series machines that
  > will find this useful.


Ok, that's quite sensible. Then I'd like to add some documentation
either to Documentation/networking/netdevices.txt or a new file (say
Documentation/networking/ipv6-addrconf.txt) to describe the new
feature.  Although netdevices.txt seems to be rather incomplete, I
think the description of this netdevice feature belongs herein.


Any other thoughts, comments regarding the patch?


Andreas


--
Linux for eServer Development
Tel :  +49-7031-16-4640
Notes mail :  Andreas Herrmann/GERMANY/IBM@IBMDE
email :  aherrman@de.ibm.com
