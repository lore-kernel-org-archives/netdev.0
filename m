From: Michael Riepe <michael.riepe@googlemail.com>
Subject: Re: 2.6.27.19 + 28.7: network timeouts for r8169 and 8139too
Date: Tue, 12 May 2009 23:45:55 +0200
Message-ID: <4A09EE13.3020102@googlemail.com>
References: <200903041828.49972.m.bueker@berlin.de>	<4A06D8D2.4010505@googlemail.com>	<1242001754.4093.12.camel@obelisk.thedillows.org>	<200905112248.44868.mb@bu3sch.de> <m3eiuufufj.fsf@intrepid.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Michael Buesch <mb@bu3sch.de>, David Dillow <dave@thedillows.org>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Rui Santos <rsantos@grupopie.com>,
	=?ISO-8859-15?Q?Michael_B=FCker?= <m.bueker@berlin.de>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Krzysztof Halasa <khc@pm.waw.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fg-out-1718.google.com ([72.14.220.157]:30092 "EHLO
	fg-out-1718.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751271AbZELVp7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 May 2009 17:45:59 -0400
In-Reply-To: <m3eiuufufj.fsf@intrepid.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Krzysztof Halasa wrote:
> Michael Buesch <mb@bu3sch.de> writes:
> 
> 
>>Yeah maybe other chips are affected as well.
>>I just want to note that my failing chip/board is an Intel D945GCLF2 board
>>with onboard G-LAN, too.
>>
>>The device XID is: XID 3c4000c0
> 
> 
> I have an on-board RTL8111C (at least the docs say so) with this same
> XID and it's working correctly.

How do lspci and dmesg report the chip? For mine, lspci says it's a
"RTL8111/8168B PCI Express Gigabit Ethernet controller (rev 02)" while
the kernel reports "RTL8168c/8111c at 0xffffc200000f6000,
00:1c:c0:b6:1a:4a, XID 3c4000c0".

This reminds me of the early ATA/USB bridges from Genesys Logic... many
revisions, and each one broken in a different way. :-(

-- 
Michael "Tired" Riepe <michael.riepe@googlemail.com>
X-Tired: Each morning I get up I die a little
