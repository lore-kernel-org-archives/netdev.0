From: Michael Buesch <mb@bu3sch.de>
Subject: Re: Please pull bcm43xx-d80211 bugfixes and new features
Date: Tue, 3 Oct 2006 15:05:02 +0200
Message-ID: <200610031505.03129.mb@bu3sch.de>
References: <200610021843.20694.mb@bu3sch.de> <200610031358.33760.mb@bu3sch.de> <20061003123621.GA4673@tuba>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Martin Langer <martin-langer@gmx.de>,
	Larry Finger <Larry.Finger@lwfinger.net>,
	linville@tuxdriver.com, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from static-ip-62-75-166-246.inaddr.intergenia.de ([62.75.166.246]:39865
	"EHLO bu3sch.de") by vger.kernel.org with ESMTP id S932149AbWJCNFc
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Oct 2006 09:05:32 -0400
To: bcm43xx-dev@lists.berlios.de
In-Reply-To: <20061003123621.GA4673@tuba>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tuesday 03 October 2006 14:36, Martin Langer wrote:
> On Tue, Oct 03, 2006 at 01:58:33PM +0200, Michael Buesch wrote:
> > On Tuesday 03 October 2006 05:44, Larry Finger wrote:
> > > 
> > > kernel: ssb: Core 0 found: cc 0800, rev 02, vendor 4243
> > > kernel: ssb: Core 1 found: cc 0812, rev 04, vendor 4243
> > > kernel: ssb: Core 2 found: cc 080D, rev 01, vendor 4243
> > > kernel: ssb: Core 3 found: cc 0807, rev 01, vendor 4243
> > > kernel: ssb: Core 4 found: cc 0804, rev 07, vendor 4243
> > > kernel: ssb: Core 5 found: cc 0812, rev 04, vendor 4243
> > > kernel: bcm43xx_d80211: Ignoring additional 802.11 core.
> > > kernel: bcm43xx_d80211: Broadcom 4306 WLAN found
> > > kernel: ssb: Switching to core 4
> > > kernel: bcm43xx_d80211: PHY connected
> > > kernel: ssb: Switching to core 1
> > > kernel: bcm43xx_d80211: Detected PHY: Version: 1, Type 2, Revision 1
> > > kernel: bcm43xx_d80211: Detected Radio: ID: 2205017f (Manuf: 17f Ver: 2050 Rev: 2)
> > > kernel: bcm43xx_d80211: Radio turned off
> > > kernel: bcm43xx_d80211: Radio turned off
> > > kernel: wmaster0: Selected rate control algorithm 'simple'
> > > kernel: bcm43xx_d80211: Virtual interface added (type: 0x00000002, ID: 4, MAC: 00
> > > :06:25:40:6f:03)
> > > kernel: bcm43xx_d80211: PHY connected
> > > kernel: bcm43xx_d80211: PHY disconnected
> > > kernel: bcm43xx_d80211: PHY connected
> > > kernel: bcm43xx_d80211: firmware revision FE84, patchlevel 90B4, date 2000-14-248
> > >   29:46:18
> > 
> > Uhm, which firmware are you running?
> 
> v4 testers should use the SVN version of fwcutter. There was a v4 
> windriver bug in fwcutter .... some time ago.

For convenience I modified current fwcutter to not reject v4 firmware files
(but print a big fat warning) and tagged the 005 release here:
http://prdownload.berlios.de/bcm43xx/bcm43xx-fwcutter-005.tar.bz2

-- 
Greetings Michael.
