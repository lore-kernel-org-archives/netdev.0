From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-2.6.24] introduce MAC_FMT/MAC_ARG
Date: Fri, 24 Aug 2007 23:14:35 -0700 (PDT)
Message-ID: <20070824.231435.77347129.davem@davemloft.net>
References: <1187884912.32738.24.camel@localhost>
	<1187885520.22725.4.camel@johannes.berg>
	<20070823170830.GE2989@tuxdriver.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: johannes@sipsolutions.net, joe@perches.com, netdev@vger.kernel.org
To: linville@tuxdriver.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38655
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751469AbXHYGOg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Aug 2007 02:14:36 -0400
In-Reply-To: <20070823170830.GE2989@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: "John W. Linville" <linville@tuxdriver.com>
Date: Thu, 23 Aug 2007 13:08:30 -0400

> On Thu, Aug 23, 2007 at 06:12:00PM +0200, Johannes Berg wrote:
> > On Thu, 2007-08-23 at 09:01 -0700, Joe Perches wrote:
> > > There are also several different uses of the equivalent of
> > > 
> > > 	printk("%02x",addr[0])
> > > 	for (i=1; i<6; i++)
> > > 		printk(":%02x",addr[i]);
> > > 
> > > to print an ethernet MAC address.
> > 
> > Hm. I didn't know that, I can go through in a later patch if desired.
> > 
> > > http://www.uwsg.iu.edu/hypermail/linux/net/0602.1/0002.html
> > > 
> > > As not all device MAC addresses are 6 bytes, colon separated,
> > > perhaps an appropriate ethernet/tr MAC designation is EUI48.
> > > 
> > > http://standards.ieee.org/regauth/oui/tutorials/EUI48.html
> > 
> > Practically, however, nobody is going to even find macros named
> > EUI48_FMT/EUI48_ARG, would they? I don't much care, but I find it rather
> > unsatisfying that both wireless code bases define these macros.
> 
> Yeah, accomodating non-48-bit MAC addresses is a bit pedantic.
> 
> I ACK the original patch, FWIW.

I like the patch too, applied to net-2.6.24, thanks everyone.
