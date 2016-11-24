From: Aaro Koskinen <aaro.koskinen@iki.fi>
Subject: Re: wl1251 & mac address & calibration data
Date: Thu, 24 Nov 2016 20:46:01 +0200
Message-ID: <20161124184601.wo4al6nyzb6rmiqs@raspberrypi-2.musicnaut.iki.fi>
References: <201611111820.52072@pali>
 <201611221805.13606@pali>
 <20161123222335.GA4788@amd>
 <201611232339.59411@pali>
 <20161124075104.GA26721@amd>
 <20161124083329.GB13735@pali>
 <20161124151317.34yoza3dzuh46oa4@earth>
 <20161124152045.GK13735@pali>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: 8bit
Cc: Sebastian Reichel <sre@kernel.org>, Pavel Machek <pavel@ucw.cz>,
        Michal Kazior <michal.kazior@tieto.com>,
        Kalle Valo <kvalo@codeaurora.org>,
        Ivaylo Dimitrov <ivo.g.dimitrov.75@gmail.com>,
        Tony Lindgren <tony@atomide.com>,
        linux-wireless <linux-wireless@vger.kernel.org>,
        Network Development <netdev@vger.kernel.org>,
        linux-kernel@vger.kernel.org
To: Pali =?iso-8859-1?Q?Roh=E1r?= <pali.rohar@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20161124152045.GK13735@pali>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On Thu, Nov 24, 2016 at 04:20:45PM +0100, Pali Rohár wrote:
> Proprietary, signed and closed bootloader NOLO does not support DT. So
> for booting you need to append DTS file to kernel image.
> 
> U-Boot is optional and can be used as intermediate bootloader between
> NOLO and kernel. But still it has problems with reading from nand, so
> cannot read NVS data nor MAC address.

You could use kexec to pass the fixed DT.

A.
