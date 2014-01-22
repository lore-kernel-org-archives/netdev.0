From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: r8169 won't transmit with 3.12
Date: Thu, 23 Jan 2014 00:31:35 +0100
Message-ID: <20140122233135.GA800@electric-eye.fr.zoreil.com>
References: <20140121000615.GA30495@enc.com.au>
 <20140121233630.GA3214@electric-eye.fr.zoreil.com>
 <20140122004119.GA28174@enc.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Realtek linux nic maintainers <nic_swsd@realtek.com>,
	netdev@vger.kernel.org
To: Craig Small <csmall@enc.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:38851 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752960AbaAVXbu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 22 Jan 2014 18:31:50 -0500
Content-Disposition: inline
In-Reply-To: <20140122004119.GA28174@enc.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Craig Small <csmall@enc.com.au> :
> On Wed, Jan 22, 2014 at 12:36:30AM +0100, Francois Romieu wrote:
> > You may check that the onboard nic device does not even work when the
> > extra PCI-e card aren't plugged.
> It definitely doesn't. I've tried with only the onboard device
> and no other NIC device (r8169 or not) installed and its the same
> problem.

Should I understand that the LOM fails on Linux with a naked motherboard ?

> > A complete dmesg including the XID lines that the r8169 driver prints
> > would be welcome.
> See attached text file. I'm not sure why I get so many interface up
> messages.

Please check if runtime resume is disabled (/sys/bus/pci/devices/.../power/control
should be 'on'). If so and you do not see many netdev watchdog messages either,
these could be real link status change events.

> This is for the two NIC cards. I can pull them out and go back to the
> onboard one if you like.

Please do (and send a complete dmesg).

Your previous posting suggests that the LOM board is a 8168b but I haven't
seen its XID.

It could help to check the add-on 8168c in a different computer whose
motherboard does not include any networking chipset from Realtek (nor
any bios that could confuse different revisions of those).

Please don't switch between the r8168 and the r8169 modules at runtime.
I saw it in your dmesg and I won't claim it's supported.

I'll be out for work during two days.

Thanks.

-- 
Ueimor
