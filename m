From: "Andreas Herrmann" <AHERRMAN@de.ibm.com>
Subject: Re: [PATCH] new net device feature: shared-ipv6-cards
Date: Wed, 21 Aug 2002 19:00:39 +0200
Sender: owner-netdev@oss.sgi.com
Message-ID: <OF55880994.F5346670-ONC1256C1C.005D4FB1@de.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@redhat.com, netdev@oss.sgi.com, owner-netdev@oss.sgi.com,
   pekkas@netcore.fi
Return-path: <owner-netdev@oss.sgi.com>
To: kuznet@ms2.inr.ac.ru
List-Id: netdev.vger.kernel.org

      kuznet@ms2.inr.ac.ru
      Sent by: owner-netdev@oss.sgi.com
      08/21/02 05:55 PM

  > One thought: if you have to add a new field to struct netdevice,
  > it makes lots of sense to move further and to add special method
  > dev->generate_eui64() instead, which will be initialized
  > to standard eth_generate_eui64() for normal ethernets
  > and to something private for your device.

I agree with this. Of course this implies changes in the device driver
itself. (Currently our device driver for the shared cards relies on
the changes described in the patch.)
But its the way it should be done.

  > In this way we are guaranteed not to have problems of this kind
  > in future.

What about implementing your alternative proposal in 2.5 and to use
the current approach in a next 2.4.x kernel?


Regards,

Andreas

--
Linux for eServer Development
Tel :  +49-7031-16-4640
Notes mail :  Andreas Herrmann/GERMANY/IBM@IBMDE
email :  aherrman@de.ibm.com
