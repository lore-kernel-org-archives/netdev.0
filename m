From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: Optics (SFP) monitoring on ixgbe and igbe
Date: Thu, 15 Nov 2012 23:30:05 +0000
Message-ID: <1353022205.4867.76.camel@deadeye.wl.decadent.org.uk>
References: <CAPN4dA8WUdox2k_F_9cYw=hR=xZHia=z3CXwy-36_t9Hh58zBg@mail.gmail.com>
	 <1352318339.2725.34.camel@bwh-desktop.uk.solarflarecom.com>
	 <CAPN4dA95RQ+xyvY+qo0CDc=KmaKhuqHATx_KyMjppvauYtUyzQ@mail.gmail.com>
	 <1352473713.3159.4.camel@bwh-desktop.uk.solarflarecom.com>
	 <CAPN4dA_kb4Gy6JWEW1h4YsGf5QwsOz58gGJqS0OcPTvHoAL7Xw@mail.gmail.com>
	 <CAPN4dA-moLxn_jQW4e906j9wLU+tZVLxvkWeLOxDEbZpGtJ28g@mail.gmail.com>
	 <50A570D7.3080409@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>, <jeffrey.t.kirsher@intel.com>
To: <footplus@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:55737 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750794Ab2KOXaJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Nov 2012 18:30:09 -0500
In-Reply-To: <50A570D7.3080409@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-11-15 at 14:46 -0800, Jeff Kirsher wrote:
> On 11/15/2012 01:36 PM, Aur=C3=A9lien wrote:
> >> On Fri, Nov 9, 2012 at 4:08 PM, Ben Hutchings <bhutchings@solarfla=
re.com> wrote:
> >>> No, the driver also needs to implement ethtool_ops::get_module_in=
fo and
> >>> ethtool_ops::get_module_eeprom.  But those should be quite easy t=
o do.
> >>>
> > Hi !
> >
> > I started to implement these operations in ixgbe.
> >
> > So far, the result is the attached patch, which applies on dave-m's
> > net-next @ 1ff05fb7114a6b4118e0f7d89fed2659f7131b0a. It's not yet
> > finished, and since it is my first peek at network drivers I need s=
ome
> > advice on:
> >
> > - whether the implementation seems correct for ixgbe and all its
> > supported MAC/PHY combinations ?
> > - what would be the best way to manage SFF-8472 A0/A2 bank swapping
> > mechanism for reading A2h ? (it seems I need to lock the whole -
> > adress change sequence - read A2h - address change again - operatio=
n)
> > in case it's needed. I may not be able to test that, so I may add a=
n
> > unsupported return code for now.
> > - Is the supported PHY selection correct, or should other PHYs be
> > supported ? What should be the rule ?
> >
> > I have been able to get correct temperature readings with a patched=
-up
> > ethtool, so it seems to work correctly on at least my card (Etherne=
t
> > controller [0200]: Intel Corporation 82599EB 10-Gigabit Network
> > Connection [8086:10fb] (rev 01)).
> >
> > About ethtool, I was thinking about making a -O option for optical
> > diagnostics, which would have a readable output. I will make a
> > function to parse the A2 register contents, so it can be reused in
> > other daemons/libs (SNMP, etc).
> >
> > Thanks,
> > Best regards,
> Can you please add me <jeffrey.t.kirsher@intel.com> to the CC on futu=
re
> patches for ixgbe or ixgb, as I will be the one applying the patch to=
 my
> queue?

Yes, Jeff's the one you should be talking to about these drivers.  I
just look after the ethtool utility and API.

Ben.

--=20
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
