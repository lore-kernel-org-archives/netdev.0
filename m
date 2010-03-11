From: "Michael Chan" <mchan@broadcom.com>
Subject: Re: BNX2: Kernel crashes with 2.6.31 and 2.6.31.9
Date: Thu, 11 Mar 2010 09:49:56 -0800
Message-ID: <1268329796.9775.125.camel@nseg_linux_HP1.broadcom.com>
References: <20091229084929.54912c0c@pluto.restena.lu>
 <1262077540.12520.4.camel@localhost>
 <20091229145403.39f82773@pluto.restena.lu>
 <1262149691.2788.63.camel@localhost>
 <20100219091034.5fbb0165@pluto.restena.lu>
 <1266609426.2610.36.camel@dhcp-10-12-137-130.broadcom.com>
 <20100223131508.4c6cb866@neptune.home>
 <1267493170.2762.45.camel@dhcp-10-12-137-104.broadcom.com>
 <20100302081051.3d1b1c53@pluto.restena.lu>
 <20100302092020.52cfcd0e@pluto.restena.lu>
 <1267567926.19491.175.camel@nseg_linux_HP1.broadcom.com>
 <4B90189B.2040801@hp.com> <4B98268D.2020206@hp.com>
 <1268263973.9775.95.camel@nseg_linux_HP1.broadcom.com>
 <4B9850DC.9060703@hp.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Bruno =?ISO-8859-1?Q?Pr=E9mont?=" <bonbons@linux-vserver.org>,
	"Benjamin Li" <benli@broadcom.com>,
	NetDEV <netdev@vger.kernel.org>,
	Linux-Kernel <linux-kernel@vger.kernel.org>
To: "Brian Haley" <brian.haley@hp.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4B9850DC.9060703@hp.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


On Wed, 2010-03-10 at 18:09 -0800, Brian Haley wrote:
> >> I'm able to cause a netdev_watchdog timeout by changing the coalesce
> >> settings on my bnx2, I built a little test program for it:
> > 
> > Do you run this program in a loop?  How quickly do you see the NETDEV
> > WATCHDOG?
> 
> It's run once, and we see it almost immediately after ETHTOOL_SCOALESCE.

What's the difference between running the test program and doing ethtool
-C?  Do you see the issue in either case?  I don't see the issue here
with ethtool -C.

Thanks.
