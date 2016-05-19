From: Alexander Stein <alexander.stein@systec-electronic.com>
Subject: Re: [PATCH 1/1 RFC] net/phy: Add Lantiq PHY driver
Date: Thu, 19 May 2016 09:28 +0200
Message-ID: <2585855.A9idatFmvt@ws-stein>
References: <1463587403-26809-1-git-send-email-alexander.stein@systec-electronic.com> <1712340.89M2Ezzzk6@ws-stein> <5f2d9a6d-bcf1-5aa1-7c45-f8cfd723bc3a@phrozen.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7Bit
Cc: Florian Fainelli <f.fainelli@gmail.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, andrew@lunn.ch,
	Mathias Kresin <openwrt@kresin.me>,
	"Mehrtens, Hauke" <hauke.mehrtens@intel.com>
To: John Crispin <john@phrozen.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webbox1416.server-home.net ([77.236.96.61]:46099 "EHLO
	webbox1416.server-home.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751362AbcESH2H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 May 2016 03:28:07 -0400
In-Reply-To: <5f2d9a6d-bcf1-5aa1-7c45-f8cfd723bc3a@phrozen.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thursday 19 May 2016 09:03:26, John Crispin wrote:
> [ changing haukes mail addr to the intel one ]
> 
> On 19/05/2016 08:57, Alexander Stein wrote:
> > Hi John,
> > 
> > On Thursday 19 May 2016 06:50:56, John Crispin wrote:
> >> On 18/05/2016 18:24, Florian Fainelli wrote:
> >>> CC'ing Andrew, John,
> >> 
> >> also CC'ing Matthias and Hauke. we have had a driver in OpenWrt/LEDE for
> >> several years that seems a little more complete than this one.
> >> 
> >> https://git.lede-project.org/?p=source.git;a=blob;f=target/linux/lantiq/p
> >> atc
> >> hes-4.4/0023-NET-PHY-adds-driver-for-lantiq-PHY11G.patch;h=93bb4275ec1d2
> >> 61f3 98afb8fdc879c1dd973f997;hb=HEAD
> > 
> > Thanks for the link, I wasn't aware of that patch. I like it in general,
> > but there are some things I'd like to get addressed first:
> > * vr9_gphy_of_reg_init() writes uncoditionally to led3h and led3l even on
> > 
> >   PEf7071 which does not have this register at all
> 
> we use this driver mainly on the 11g and 22f version. mathias recently
> added the led3 handling.
> 
> @Mathias, can you have a look at this and fix it inside the lede tree ?
> 
> > * Why is PHY_HAS_INTERRUPT commented out everywhere?
> 
> legacy code, the old mips silicon had a bug and the internal phys irq
> lines worked unreliably so we used polling instead. rather than remove
> the code i just disabled that part. code is not cleaned up yet for
> upstream submission as you can tell :-)

Would you or Mathias mind dropping a cleaned up patch to netdev ml, cc'ing me? 
I can try it on our hardware using the 11g. Maybe I can even test the IRQ 
feature.

Regards,
Alexander
