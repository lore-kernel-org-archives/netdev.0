From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [PATCH net-2.6.24] introduce MAC_FMT/MAC_ARG
Date: Thu, 23 Aug 2007 13:08:30 -0400
Message-ID: <20070823170830.GE2989@tuxdriver.com>
References: <1187808408.4314.15.camel@johannes.berg> <1187884912.32738.24.camel@localhost> <1187885520.22725.4.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Joe Perches <joe@perches.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ra.tuxdriver.com ([70.61.120.52]:4441 "EHLO ra.tuxdriver.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1765557AbXHWRtb (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 23 Aug 2007 13:49:31 -0400
Content-Disposition: inline
In-Reply-To: <1187885520.22725.4.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 23, 2007 at 06:12:00PM +0200, Johannes Berg wrote:
> On Thu, 2007-08-23 at 09:01 -0700, Joe Perches wrote:
> > There are also several different uses of the equivalent of
> > 
> > 	printk("%02x",addr[0])
> > 	for (i=1; i<6; i++)
> > 		printk(":%02x",addr[i]);
> > 
> > to print an ethernet MAC address.
> 
> Hm. I didn't know that, I can go through in a later patch if desired.
> 
> > http://www.uwsg.iu.edu/hypermail/linux/net/0602.1/0002.html
> > 
> > As not all device MAC addresses are 6 bytes, colon separated,
> > perhaps an appropriate ethernet/tr MAC designation is EUI48.
> > 
> > http://standards.ieee.org/regauth/oui/tutorials/EUI48.html
> 
> Practically, however, nobody is going to even find macros named
> EUI48_FMT/EUI48_ARG, would they? I don't much care, but I find it rather
> unsatisfying that both wireless code bases define these macros.

Yeah, accomodating non-48-bit MAC addresses is a bit pedantic.

I ACK the original patch, FWIW.

John
-- 
John W. Linville
linville@tuxdriver.com
