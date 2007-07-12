From: Mike Anderson <andmike@us.ibm.com>
Subject: Re: [2.6.23 PATCH 13/18] dm: netlink
Date: Thu, 12 Jul 2007 06:42:43 -0700
Message-ID: <20070712134242.GA1671@us.ibm.com>
References: <20070711142712.e646995b.akpm@linux-foundation.org>
	<20070711233736.GA29241@us.ibm.com>
	<20070712081028.GB25699@2ka.mipt.ru>
	<20070712.032727.07453420.davem@davemloft.net>
Reply-To: device-mapper development <dm-devel@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: johnpol@2ka.mipt.ru, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, dm-devel@redhat.com,
	akpm@linux-foundation.org, agk@redhat.com
To: David Miller <davem@davemloft.net>
Return-path: <dm-devel-bounces@redhat.com>
Content-Disposition: inline
In-Reply-To: <20070712.032727.07453420.davem@davemloft.net>
List-Unsubscribe: <https://www.redhat.com/mailman/listinfo/dm-devel>,
	<mailto:dm-devel-request@redhat.com?subject=unsubscribe>
List-Archive: <https://www.redhat.com/archives/dm-devel>
List-Post: <mailto:dm-devel@redhat.com>
List-Help: <mailto:dm-devel-request@redhat.com?subject=help>
List-Subscribe: <https://www.redhat.com/mailman/listinfo/dm-devel>,
	<mailto:dm-devel-request@redhat.com?subject=subscribe>
Sender: dm-devel-bounces@redhat.com
Errors-To: dm-devel-bounces@redhat.com
List-Id: netdev.vger.kernel.org

David Miller <davem@davemloft.net> wrote:
> From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
> Date: Thu, 12 Jul 2007 12:10:29 +0400
> 
> > On Wed, Jul 11, 2007 at 04:37:36PM -0700, Mike Anderson (andmike@us.ibm.com) wrote:
> > > > > --- linux.orig/include/linux/netlink.h	2007-07-11 21:37:31.000000000 +0100
> > > > > +++ linux/include/linux/netlink.h	2007-07-11 21:37:50.000000000 +0100
> > > > > @@ -21,7 +21,7 @@
> > > > >  #define NETLINK_DNRTMSG		14	/* DECnet routing messages */
> > > > >  #define NETLINK_KOBJECT_UEVENT	15	/* Kernel messages to userspace */
> > > > >  #define NETLINK_GENERIC		16
> > > > > -/* leave room for NETLINK_DM (DM Events) */
> > > > > +#define NETLINK_DM		17	/* Device Mapper */
> > > > >  #define NETLINK_SCSITRANSPORT	18	/* SCSI Transports */
> > > > >  #define NETLINK_ECRYPTFS	19
> > > > 
> > > > Have the net guys checked this?  
> > > 
> > > No. The support is a derivative of the netlink support in
> > > scsi_transport_iscsi.c.
> > 
> > I'm not sure about all net guys, but the first question rised after
> > reading this - why do you want special netlink family and do not want to
> > use interfaces created on top of - like connector and genetlink?
> 
> I agree, there is really no reason to not at least use
> genetlink.

ok, I will switch over to using genetlink.

-andmike
--
Michael Anderson
andmike@us.ibm.com
