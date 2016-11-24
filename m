From: Pali =?utf-8?B?Um9ow6Fy?= <pali.rohar@gmail.com>
Subject: Re: wl1251 & mac address & calibration data
Date: Thu, 24 Nov 2016 09:33:29 +0100
Message-ID: <20161124083329.GB13735@pali>
References: <201611111820.52072@pali>
 <201611221805.13606@pali>
 <20161123222335.GA4788@amd>
 <201611232339.59411@pali>
 <20161124075104.GA26721@amd>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: Michal Kazior <michal.kazior@tieto.com>,
        Kalle Valo <kvalo@codeaurora.org>,
        Ivaylo Dimitrov <ivo.g.dimitrov.75@gmail.com>,
        Sebastian Reichel <sre@kernel.org>,
        Aaro Koskinen <aaro.koskinen@iki.fi>,
        Tony Lindgren <tony@atomide.com>,
        linux-wireless <linux-wireless@vger.kernel.org>,
        Network Development <netdev@vger.kernel.org>,
        linux-kernel@vger.kernel.org
To: Pavel Machek <pavel@ucw.cz>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20161124075104.GA26721@amd>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thursday 24 November 2016 08:51:04 Pavel Machek wrote:
> Hi!
> 
> > > "ifconfig hw ether XX" normally sets the address. I guess that's
> > > ioctl?
> > 
> > This sets temporary address and it is ioctl. IIRC same as what ethtool 
> > uses. (ifconfig is already deprecated).
> > 
> > > And I guess we should use similar mechanism for permanent
> > > address.
> > 
> > I'm not sure here... Above ioctl ↑↑↑ is for changing temporary mac 
> > address. But here we do not want to change permanent mac address. We 
> > want to tell kernel driver current permanent mac address which is
> > stored
> 
> Well... I'd still use similar mechanism :-).

Thats problematic, because in time when wlan0 interface is registered
into system and visible in ifconfig output it already needs to have
permanent mac address assigned.

We should assign permanent mac address before wlan0 of wl1251 is
registered into system.

-- 
Pali Rohár
pali.rohar@gmail.com
