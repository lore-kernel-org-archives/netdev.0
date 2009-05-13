From: Michael Riepe <michael.riepe@googlemail.com>
Subject: Re: 2.6.27.19 + 28.7: network timeouts for r8169 and 8139too
Date: Wed, 13 May 2009 08:27:46 +0200
Message-ID: <4A0A6862.3020809@googlemail.com>
References: <200903041828.49972.m.bueker@berlin.de> <4A06D8D2.4010505@googlemail.com> <1242001754.4093.12.camel@obelisk.thedillows.org> <200905112248.44868.mb@bu3sch.de> <m3eiuufufj.fsf@intrepid.localdomain> <4A09EE13.3020102@googlemail.com> <20090513061138.GA11106@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Krzysztof Halasa <khc@pm.waw.pl>, Michael Buesch <mb@bu3sch.de>,
	David Dillow <dave@thedillows.org>,
	Rui Santos <rsantos@grupopie.com>,
	=?ISO-8859-15?Q?Michael_B=FCker?= <m.bueker@berlin.de>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f222.google.com ([209.85.218.222]:37603 "EHLO
	mail-bw0-f222.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752232AbZEMG1s (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 May 2009 02:27:48 -0400
In-Reply-To: <20090513061138.GA11106@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

Francois Romieu wrote:
> Michael Riepe <michael.riepe@googlemail.com> :
> [...]
> 
>>How do lspci and dmesg report the chip? For mine, lspci says it's a
>>"RTL8111/8168B PCI Express Gigabit Ethernet controller (rev 02)" while
>>the kernel reports "RTL8168c/8111c at 0xffffc200000f6000,
>>00:1c:c0:b6:1a:4a, XID 3c4000c0".
> 
> 
> The XID is more specific than the first kernel report. lspci is less
> accurate.

Then the question is: Are there two different revisions with the same
XID, or is it always the same chip that sometimes works and sometimes
doesn't?

I can't remember anybody reporting that the Intel D945GCLF2 works for
them, so it might also be an interoperability issue.

-- 
Michael "Tired" Riepe <michael.riepe@googlemail.com>
X-Tired: Each morning I get up I die a little
