From: David Miller <davem@davemloft.net>
Subject: Re: [2.6.23 PATCH 13/18] dm: netlink
Date: Thu, 12 Jul 2007 03:27:27 -0700 (PDT)
Message-ID: <20070712.032727.07453420.davem@davemloft.net>
References: <20070711142712.e646995b.akpm@linux-foundation.org>
	<20070711233736.GA29241@us.ibm.com>
	<20070712081028.GB25699@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: andmike@us.ibm.com, akpm@linux-foundation.org, agk@redhat.com,
	dm-devel@redhat.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: johnpol@2ka.mipt.ru
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48648
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1760131AbXGLK13 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jul 2007 06:27:29 -0400
In-Reply-To: <20070712081028.GB25699@2ka.mipt.ru>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Date: Thu, 12 Jul 2007 12:10:29 +0400

> On Wed, Jul 11, 2007 at 04:37:36PM -0700, Mike Anderson (andmike@us.ibm.com) wrote:
> > > > --- linux.orig/include/linux/netlink.h	2007-07-11 21:37:31.000000000 +0100
> > > > +++ linux/include/linux/netlink.h	2007-07-11 21:37:50.000000000 +0100
> > > > @@ -21,7 +21,7 @@
> > > >  #define NETLINK_DNRTMSG		14	/* DECnet routing messages */
> > > >  #define NETLINK_KOBJECT_UEVENT	15	/* Kernel messages to userspace */
> > > >  #define NETLINK_GENERIC		16
> > > > -/* leave room for NETLINK_DM (DM Events) */
> > > > +#define NETLINK_DM		17	/* Device Mapper */
> > > >  #define NETLINK_SCSITRANSPORT	18	/* SCSI Transports */
> > > >  #define NETLINK_ECRYPTFS	19
> > > 
> > > Have the net guys checked this?  
> > 
> > No. The support is a derivative of the netlink support in
> > scsi_transport_iscsi.c.
> 
> I'm not sure about all net guys, but the first question rised after
> reading this - why do you want special netlink family and do not want to
> use interfaces created on top of - like connector and genetlink?

I agree, there is really no reason to not at least use
genetlink.
