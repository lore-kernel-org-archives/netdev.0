From: Marc Haber <mh+linux-kernel@zugschlus.de>
Subject: Re: 2.6.26/tg3 ping roundtrip times > 2000 ms on local network
Date: Fri, 22 Aug 2008 13:33:32 +0200
Message-ID: <20080822113332.GD10603@torres.zugschlus.de>
References: <20080821160928.GB21967@torres.zugschlus.de> <C27F8246C663564A84BB7AB343977242024953CE46@IRVEXCHCCR01.corp.ad.broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Matthew Carlson <mcarlson@broadcom.com>,
	David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Michael Chan <mchan@broadcom.com>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757385AbYHVLdq@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <C27F8246C663564A84BB7AB343977242024953CE46@IRVEXCHCCR01.corp.ad.broadcom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Aug 21, 2008 at 09:21:28AM -0700, Michael Chan wrote:
> Marc Haber wrote:
> > On Wed, Aug 20, 2008 at 07:11:50AM -0700, Michael Chan wrote:
> > > On Wed, 2008-08-20 at 10:47 -0700, Marc Haber wrote:
> > > > Now I need to understand why the other, nearly[1]
> > identical box didn't
> > > > need the patch to function properly.
> > >
> > > It depends on whether you have ASF enabled or not and what
> > version of
> > > ASF you have.  ASF is management firmware running inside
> > the NIC.  When
> > > the tg3 driver loads, it will show ASF[1] in dmesg if ASF
> > is enabled.
> >
> > Both machines have that string in their dmesg.
> >
> 
> It may be different versions of ASF.  Try ethtool -i eth0.  It
> may tell us the firmware version.

$ sudo ethtool -i eth0
driver: tg3
version: 3.92.1
firmware-version: 5704-v3.26
bus-info: 0000:02:00.0

The other box is the same, only that bus-info ends in .1, and the .0
device is unused.

Greetings
Marc

-- 
-----------------------------------------------------------------------------
Marc Haber         | "I don't trust Computers. They | Mailadresse im Header
Mannheim, Germany  |  lose things."    Winona Ryder | Fon: *49 621 72739834
Nordisch by Nature |  How to make an American Quilt | Fax: *49 3221 2323190
