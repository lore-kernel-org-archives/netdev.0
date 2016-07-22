From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: [PATCH 2/3] staging/rtl8192e: use s8 instead of char
Date: Fri, 22 Jul 2016 21:47:10 +0200
Message-ID: <7894919.vMsHjmmMb1@wuerfel>
References: <20160719153403.2967812-1-arnd@arndb.de> <20160722043922.0a878698@mir> <wrfjoa5phop3.fsf@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Stefan Lippers-Hollmann <s.l-h@gmx.de>,
	linux-wireless@vger.kernel.org, Kalle Valo <kvalo@codeaurora.org>,
	Larry Finger <Larry.Finger@lwfinger.net>,
	netdev@vger.kernel.org,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Mateusz Kulikowski <mateusz.kulikowski@gmail.com>,
	devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org,
	Andrea Merello <andrea.merello@gmail.com>
To: Jes Sorensen <Jes.Sorensen@redhat.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <wrfjoa5phop3.fsf@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday, July 22, 2016 7:55:36 AM CEST Jes Sorensen wrote:
> Stefan Lippers-Hollmann <s.l-h@gmx.de> writes:
> > Hi
> >
> > On 2016-07-20, Arnd Bergmann wrote:
> >> On Wednesday, July 20, 2016 11:33:43 AM CEST Jes Sorensen wrote:
> >> > Arnd Bergmann <arnd@arndb.de> writes:  
> >> > > On Wednesday, July 20, 2016 7:25:19 AM CEST Jes Sorensen wrote:  
> >> > >> Arnd Bergmann <arnd@arndb.de> writes:
> > [...]
> >> Yes, I was just agreeing here that it's not worth doing that one.
> >> As far as I can see, the evolution of these devices is
> >> 
> >> RTL81xxU (2008)
> >> RTL81xxSU (2009)
> >> RTL81xxCU (2010)
> >
> > There is also RTL81xxDU, apparently from 2011, a dualband device
> > coming in several variants (single MAC + single PHY, double MAC +
> > double PHY and double PHY); e.g. 0bda:8194 (single PHY + single MAC).

Right. In my list above I tried to have just the ones that seem 
to each be 100% supersets of previous generations replacing the
earlier ones, which isn't true for RTL81xxDU as RTL81xxEU
reverts to single PHY.

> > While probably not overly common, it was/ is (hardware-wise) a pretty
> > interesting device due to its support for 5 GHz[1] - actually I hoped
> > it to be a (supported-) RTL8192CU variant when I bought it. 
> > Unfortunately no driver[2] made it to staging or the proper kernel.
> 
> I actually have one of those in my USB dongle box, but as you say, not
> overly common so not sure if/when I'll get to it.
> 
> Adding 8192du support for 2.4GHz to rtl8xxxu probably wouldn't be too
> complicated.

My guess is that these devices have largely been replaced by
802.11ac devices on the market, and whoever has one of the old ones
probably bought it because of the 5GHz support, so adding 2.4GHz-only
support for it may not help all that much either.

	Arnd
