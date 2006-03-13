From: "Randy.Dunlap" <rdunlap@xenotime.net>
Subject: Re: Router stops routing after changing MAC Address
Date: Mon, 13 Mar 2006 14:10:34 -0800
Message-ID: <20060313141034.c3cf0eea.rdunlap@xenotime.net>
References: <925A849792280C4E80C5461017A4B8A20321F2@mail733.InfraSupportEtc.com>
	<20060313100041.212cee08@localhost.localdomain>
	<Pine.LNX.4.61.0603131513380.5373@chaos.analogic.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: shemminger@osdl.org, GregScott@InfraSupportEtc.com,
	76306.1226@compuserve.com, linux-kernel@vger.kernel.org,
	davem@davemloft.net, netdev@vger.kernel.org, bart@samwel.tk,
	alan@lxorguk.ukuu.org.uk, smackinlay@mail.com
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S932468AbWCMWIu@vger.kernel.org>
To: "linux-os \(Dick Johnson\)" <linux-os@analogic.com>
In-Reply-To: <Pine.LNX.4.61.0603131513380.5373@chaos.analogic.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 13 Mar 2006 15:27:26 -0500 linux-os \(Dick Johnson\) wrote:

> 
> On Mon, 13 Mar 2006, Stephen Hemminger wrote:
> 
> > There still is a bug in the 3c59x driver.  It doesn't include any code
> > to handle changing the mac address.  It will work if you take the device
> > down, change address, then bring it up. But you shouldn't have to do that.
> >
> > Also, if the driver handles setting mac address, it could have prevented
> > you from using a multicast address.
> >
> > Something like this is needed (untested, I don't have that hardware).
> >
[cut patch]

> Actually, it doesn't make any difference. Changing the IEEE station
> (physical) address is not an allowed procedure even though hooks are
> available in many drivers to do this. According to the IEEE 802
> physical media specification, this 48-bit address must be unique and
> must be one of a group assigned by IEEE. Failure to follow this
> simple protocol can (will) cause an entire network to fail. If
> you don't care, then you certainly don't care about multicast
> bits either, basically let them set it to all ones as well.

They used to allow "Locally Administered Addresses."  Hrm,
google still finds 18,000 hits for that phrase.  Is that now
outlawed?

Even ieee.org has hit(s) for it:
http://standards.ieee.org/regauth/groupmac/tutorial.html

http://en.wikipedia.org/wiki/MAC_address
http://www.mynetwatchman.com/pckidiot/chap04.htm

---
~Randy
You can't do anything without having to do something else first.
-- Belefant's Law
