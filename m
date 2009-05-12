From: Krzysztof Halasa <khc@pm.waw.pl>
Subject: Re: 2.6.27.19 + 28.7: network timeouts for r8169 and 8139too
Date: Tue, 12 May 2009 13:10:40 +0200
Message-ID: <m3eiuufufj.fsf@intrepid.localdomain>
References: <200903041828.49972.m.bueker@berlin.de>
	<4A06D8D2.4010505@googlemail.com>
	<1242001754.4093.12.camel@obelisk.thedillows.org>
	<200905112248.44868.mb@bu3sch.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Dillow <dave@thedillows.org>,
	Michael Riepe <michael.riepe@googlemail.com>,
	Francois Romieu <romieu@fr.zoreil.com>,
	Rui Santos <rsantos@grupopie.com>,
	Michael =?iso-8859-2?Q?B=FCker?= <m.bueker@berlin.de>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Michael Buesch <mb@bu3sch.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from khc.piap.pl ([195.187.100.11]:34301 "EHLO khc.piap.pl"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755149AbZELLKl (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 May 2009 07:10:41 -0400
In-Reply-To: <200905112248.44868.mb@bu3sch.de> (Michael Buesch's message of "Mon\, 11 May 2009 22\:48\:44 +0200")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Michael Buesch <mb@bu3sch.de> writes:

> Yeah maybe other chips are affected as well.
> I just want to note that my failing chip/board is an Intel D945GCLF2 board
> with onboard G-LAN, too.
>
> The device XID is: XID 3c4000c0

I have an on-board RTL8111C (at least the docs say so) with this same
XID and it's working correctly.

$ uname -rm
2.6.29.1 x86_64

$ grep eth0 /proc/interrupts
 30:      49224      49283   PCI-MSI-edge      eth0

The board is MSI (nomen omen) P45 neo2.
-- 
Krzysztof Halasa
