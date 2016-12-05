From: Tony Lindgren <tony@atomide.com>
Subject: Re: wl1251 & mac address & calibration data
Date: Mon, 5 Dec 2016 15:51:49 -0800
Message-ID: <20161205235149.GL4705@atomide.com>
References: <201611111820.52072@pali>
 <20161124152045.GK13735@pali>
 <20161124184601.wo4al6nyzb6rmiqs@raspberrypi-2.musicnaut.iki.fi>
 <201611261820.47995@pali>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8BIT
Cc: Aaro Koskinen <aaro.koskinen@iki.fi>,
        Sebastian Reichel <sre@kernel.org>,
        Pavel Machek <pavel@ucw.cz>,
        Michal Kazior <michal.kazior@tieto.com>,
        Kalle Valo <kvalo@codeaurora.org>,
        Ivaylo Dimitrov <ivo.g.dimitrov.75@gmail.com>,
        linux-wireless <linux-wireless@vger.kernel.org>,
        Network Development <netdev@vger.kernel.org>,
        linux-kernel@vger.kernel.org
To: Pali =?utf-8?B?Um9ow6Fy?= <pali.rohar@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <201611261820.47995@pali>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Pali Rohár <pali.rohar@gmail.com> [161126 09:21]:
> On Thursday 24 November 2016 19:46:01 Aaro Koskinen wrote:
> > Hi,
> > 
> > On Thu, Nov 24, 2016 at 04:20:45PM +0100, Pali Rohár wrote:
> > > Proprietary, signed and closed bootloader NOLO does not support DT.
> > > So for booting you need to append DTS file to kernel image.
> > > 
> > > U-Boot is optional and can be used as intermediate bootloader
> > > between NOLO and kernel. But still it has problems with reading
> > > from nand, so cannot read NVS data nor MAC address.
> > 
> > You could use kexec to pass the fixed DT.
> > 
> > A.
> 
> IIRC it was broken for N900/omap3, no idea if somebody fixed it.

FYI, at least in next-20161205 kexec works on omap3 for me.

Regards,

Tony
