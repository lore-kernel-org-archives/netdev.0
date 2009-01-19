From: "Rafael J. Wysocki" <rjw@sisk.pl>
Subject: Re: [2.6.29-rc2 regression] e100: netconsole not functional because of missing firmware
Date: Mon, 19 Jan 2009 20:20:34 +0100
Message-ID: <200901192020.35116.rjw@sisk.pl>
References: <200901171908.28533.arvidjaar@mail.ru> <4807377b0901191030g27efac79rbd39501eb2eea4cb@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Andrey Borzenkov <arvidjaar@mail.ru>,
	e1000-devel@lists.soutceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, David Woodhouse <dwmw2@infradead.org>
To: Jesse Brandeburg <jesse.brandeburg@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ogre.sisk.pl ([217.79.144.158]:39200 "EHLO ogre.sisk.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752182AbZASTU6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 19 Jan 2009 14:20:58 -0500
In-Reply-To: <4807377b0901191030g27efac79rbd39501eb2eea4cb@mail.gmail.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Monday 19 January 2009, Jesse Brandeburg wrote:
> On Sat, Jan 17, 2009 at 8:08 AM, Andrey Borzenkov <arvidjaar@mail.ru> wrote:
> > [    2.008509] e100: eth0: e100_request_firmware: Failed to load
> > firmware "e100/d101m_ucode.bin": -22
> > [    2.010461] netconsole: failed to open eth0
> > [    2.010996] netconsole: cleaning up
> >
> > This has been working all the time without requiring any external
> > firmware to be present. Why it suddenly refuses to work now?
> 
> to use netconsole you probably need to set config option
> CONFIG_FIRMWARE_IN_KERNEL=y
> 
> Hm, I wonder if we couldn't have netconsole=y select
> CONFIG_FIRMWARE_IN_KERNEL in Kconfig
> 
> the arguments as to why the firmware was split out of the drivers have
> already been made on this list.  Not that I agree with them, but the
> decision has been made and we're (network devs) going along with it.

Still, if that leads to functional regressions, like this one, we need to do
something about it IMO.  David?

Thanks,
Rafael
