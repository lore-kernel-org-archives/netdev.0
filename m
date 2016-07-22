From: Stefan Lippers-Hollmann <s.l-h@gmx.de>
Subject: Re: [PATCH 2/3] staging/rtl8192e: use s8 instead of char
Date: Fri, 22 Jul 2016 22:51:35 +0200
Message-ID: <20160722225135.2b2dd751@mir>
References: <20160719153403.2967812-1-arnd@arndb.de>
	<20160722043922.0a878698@mir>
	<wrfjoa5phop3.fsf@redhat.com>
	<7894919.vMsHjmmMb1@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jes Sorensen <Jes.Sorensen@redhat.com>,
	linux-wireless@vger.kernel.org, Kalle Valo <kvalo@codeaurora.org>,
	Larry Finger <Larry.Finger@lwfinger.net>,
	netdev@vger.kernel.org,
	Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
	Mateusz Kulikowski <mateusz.kulikowski@gmail.com>,
	devel@driverdev.osuosl.org, linux-kernel@vger.kernel.org,
	Andrea Merello <andrea.merello@gmail.com>
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <7894919.vMsHjmmMb1@wuerfel>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi

On 2016-07-22, Arnd Bergmann wrote:
> On Friday, July 22, 2016 7:55:36 AM CEST Jes Sorensen wrote:
> > Stefan Lippers-Hollmann <s.l-h@gmx.de> writes:  
> > > On 2016-07-20, Arnd Bergmann wrote:  
> > >> On Wednesday, July 20, 2016 11:33:43 AM CEST Jes Sorensen wrote:  
> > >> > Arnd Bergmann <arnd@arndb.de> writes:    
> > >> > > On Wednesday, July 20, 2016 7:25:19 AM CEST Jes Sorensen wrote:    
> > >> > >> Arnd Bergmann <arnd@arndb.de> writes:  
[...]
> > > While probably not overly common, it was/ is (hardware-wise) a pretty
> > > interesting device due to its support for 5 GHz[1] - actually I hoped
> > > it to be a (supported-) RTL8192CU variant when I bought it. 
> > > Unfortunately no driver[2] made it to staging or the proper kernel.  
> > 
> > I actually have one of those in my USB dongle box, but as you say, not
> > overly common so not sure if/when I'll get to it.
> > 
> > Adding 8192du support for 2.4GHz to rtl8xxxu probably wouldn't be too
> > complicated.  
> 
> My guess is that these devices have largely been replaced by
> 802.11ac devices on the market, and whoever has one of the old ones
> probably bought it because of the 5GHz support, so adding 2.4GHz-only
> support for it may not help all that much either.

Talking purely for myself, I've certainly bought the rtl8192du device
because of its 5 GHz support, as I've made it a fairly hard policy for
me not to buy 2.4 GHz only devices anymore. But this doesn't mean that
a mainline driver only supporting 2.4 GHz for the time being would not be
appreciated dearly, given that the current state of the device is pretty 
much being a doorstop[1] - especially considering that 5 GHz support 
might even become a possibility at a later time, when 802.11ac devices 
start demanding most of the functionality for potentially more common 
newer chipset generations.

So even with my current personal policy of only buying 5 GHz capable 
devices, in practice you probably won't find 5 GHz only AP installations
(aside from long range/ outdoor point-to-point connections), be it 
because of the plethora of existing 2.4 GHz only devices or just because 
of the longer indoor (walls) range of the 2.4 GHz band. In practice, by 
far most of my existing wireless devices don't support 5 GHz (the router
does, of course) because of the reasons mentioned above, but replacing
older devices takes its time.

Regards
	Stefan Lippers-Hollmann

[1]	yes, I know about https://github.com/lwfinger/rtl8192du/ and
	even have a couple of clean-up patches pending[2] for the 
	kernel-version branch, but those need some further testing.
[2]	http://aptosid.com/slh/rtl8192du/kernel-version/
