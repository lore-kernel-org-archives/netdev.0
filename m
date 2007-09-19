From: Michael Buesch <mb@bu3sch.de>
Subject: Re: Please pull 'z1211' branch of wireless-2.6
Date: Wed, 19 Sep 2007 21:23:16 +0200
Message-ID: <200709192123.16884.mb@bu3sch.de>
References: <20070919181005.GB5483@tuxdriver.com> <20070919.115903.75429061.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: linville@tuxdriver.com, jeff@garzik.org, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org, dsd@gentoo.org, kune@deine-taler.de
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:54384
	"EHLO vs166246.vserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753365AbXIST0L (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Sep 2007 15:26:11 -0400
In-Reply-To: <20070919.115903.75429061.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 19 September 2007 20:59:03 David Miller wrote:
> From: "John W. Linville" <linville@tuxdriver.com>
> Date: Wed, 19 Sep 2007 14:10:05 -0400
> 
> > This patch adds z1211 (previously known as zd1211rw-mac80211),
> > a driver for Zydas ZD1211 hardware.  This driver has proven very
> > robust -- Fedora 7 uses this driver and I don't think I have any open
> > bugzillas for it.  Either the driver works well, or no one as using
> > it...given the common availability of the hardware, I have to presume
> > the former. :-)
> > 
> > This driver is mostly a port of zd1211rw to the mac80211
> > infrastructure.  In fact, most zd1211rw patches have been mirrored
> > directly to this driver for some time.  I considered merely updating
> > the existing driver with this code, but I think it is more prudent to
> > include this as a separate driver just to avoid confusion.  There is
> > some symbol clash between the two drivers, so I add a Kconfig hack
> > to ensure that only one or the other is built-in or that this one is
> > built as a module.
> > 
> > The maintainers have identified some (IMHO minor) issues with the
> > mac80211 port of this driver.  Some of them are summarized here:
> > 
> > 	http://linuxwireless.org/en/users/Drivers/zd1211rw/mac80211Issues
> > 
> > Still, I think we would be better-off having this driver upstream.
> 
> Agreed, merged into net-2.6.24, thanks John.


John, please also note that the following patch is not merged, yet.
http://bu3sch.de/patches/wireless-dev/20070915-1740/patches/006-zd-fix-tx-status.patch
Without it ratecontrol does not work. It does neither scale the rate
up nor down. This patch fixes both.
I think it got lost in a (really unrelated to the actual bug) discussion
about whether it's required or not to report status in mac80211 drivers.
(It turned out that it _is_ required).

-- 
Greetings Michael.
