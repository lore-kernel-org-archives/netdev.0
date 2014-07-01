From: Nathan Lynch <Nathan_Lynch@mentor.com>
Subject: Re: [PATCH CFT 00/30] Initial round of Freescale FEC ethernet patches
Date: Tue, 1 Jul 2014 09:21:28 -0500
Message-ID: <53B2C3E8.7030903@mentor.com>
References: <20140627151542.GL32514@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: <linux-arm-kernel@lists.infradead.org>, <netdev@vger.kernel.org>,
	Fugang Duan <B38611@freescale.com>
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay1.mentorg.com ([192.94.38.131]:37256 "EHLO
	relay1.mentorg.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756862AbaGAOVc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Jul 2014 10:21:32 -0400
In-Reply-To: <20140627151542.GL32514@n2100.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[apologies if this is a duplicate, I got a weird SMTP error from my
organization's mail server when I tried to send this yesterday]

On 06/27/2014 10:15 AM, Russell King - ARM Linux wrote:
> This is v2 of my initial round of patches (roughly half of my total
> patch set) for the Freescale FEC driver.
> 
> I'm sending this set out for comments and testing.  So far, I have
> had only one ack for one patch in this series, this is pretty poor,
> so I'm now sending it with a CFT tag instead.

FWIW I've given your fec-testing branch some testing on BD-SL-i.MX6
(Sabre Lite) with 3.16-rc2 (-rc1 has some issue with detecting the mmc).
 Mainly running glibc 'make check' with SSH, NFSv4, IPv4 on a gigabit
switch.  This workload wasn't exhibiting problems before your patches
and it does not appear to be regressed by them.

I wanted to test it because I've noticed hard-to-characterize sluggish
interactive response in SSH sessions on this system.  Like key echo
takes 0.2 seconds too long... sometimes.  I guess it could be anything,
but I haven't encountered it yet with your patches.
