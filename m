From: Ian Campbell <Ian.Campbell@eu.citrix.com>
Subject: Re: arp_notify: allow drivers to explicitly request a notification
 event.
Date: Wed, 11 Aug 2010 21:16:20 +0100
Message-ID: <1281557780.7349.1.camel@localhost.localdomain>
References: <20100811193925.GA9452@kroah.com>
	 <20100811193959.GA9470@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	"Jeremy Fitzhardinge" <jeremy@goop.org>,
	"David S. Miller" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Greg KH <greg@kroah.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:17745 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757003Ab0HKUQY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 11 Aug 2010 16:16:24 -0400
In-Reply-To: <20100811193959.GA9470@kroah.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2010-08-11 at 20:39 +0100, Greg KH wrote:
> On Wed, Aug 11, 2010 at 12:39:25PM -0700, Greg KH wrote:

> > > index 540703b..22c2abb 100644
> > > --- a/include/linux/notifier.h
> > > +++ b/include/linux/notifier.h
> > > @@ -210,6 +210,7 @@ static inline int notifier_to_errno(int ret)
> > >  #define NETDEV_POST_INIT	0x0010
> > >  #define NETDEV_UNREGISTER_BATCH 0x0011
> > >  #define NETDEV_BONDING_DESLAVE  0x0012
> > > +#define NETDEV_NOTIFY_PEERS	0x0012
> > 
> > Are you sure that you can duplicate this value?
> 
> Oh nevermind, David already fixed this up with commit
> 38117d1495e587fbb10d6e55733139a27893cef5

David did mention that he fixed up a clash at the timebut I hadn't
realised it was a separate checkin, thanks for figuring it out.

> I'll go queue that up for -stable as well :)

Cool, thanks.

Ian.


