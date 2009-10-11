From: Matt Domsch <Matt_Domsch@dell.com>
Subject: Re: PATCH: Network Device Naming mechanism and policy
Date: Sun, 11 Oct 2009 18:04:02 -0500
Message-ID: <20091011230402.GA18776@mock.linuxdev.us.dell.com>
References: <EDA0A4495861324DA2618B4C45DCB3EE5894ED@blrx3m08.blr.amer.dell.com> <20091009140000.GA18765@mock.linuxdev.us.dell.com> <20091009210909.GA9836@auslistsprd01.us.dell.com> <20091009194401.036da080@nehalam> <20091010044056.GA5350@mock.linuxdev.us.dell.com> <20091010052308.GA12458@kroah.com> <7e84ed60910111410g52ffd52bjec62576570d4b460@mail.gmail.com>
Reply-To: Matt Domsch <Matt_Domsch@dell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Greg KH <greg@kroah.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netdev@vger.kernel.org, linux-hotplug@vger.kernel.org,
	Narendra_K@dell.com, jordan_hargrave@dell.com
To: Rob Townley <rob.townley@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ausc60pc101.us.dell.com ([143.166.85.206]:47819 "EHLO
	ausc60pc101.us.dell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753671AbZJKXEk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 11 Oct 2009 19:04:40 -0400
Content-Disposition: inline
In-Reply-To: <7e84ed60910111410g52ffd52bjec62576570d4b460@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Oct 11, 2009 at 04:10:03PM -0500, Rob Townley wrote:
> So when an add-in PCI NIC has a lower MAC than the motherboard NICs,
> the add-in cards will come before the motherboard NICs.   i don't like it.

Actually, MAC address has nothing to do with device naming/ordering at
all.  Often systems will have onboard NICs in ascending MAC address
order, but that's not a requirement, and I've seen systems not do
that.  And once you get to add-in vs onboard, BIOS wouldn't be able to
enforce such an ordering anyhow (in general).

But yes, you raise the point that, without using MAC-assigned names or
another naming mechanism designed to cope with this, adding or
removing a card can cause a difference in device enumeration, and thus
name.

-- 
Matt Domsch
Technology Strategist, Dell Office of the CTO
linux.dell.com & www.dell.com/linux
