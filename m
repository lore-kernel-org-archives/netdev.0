From: "Gilles Espinasse" <g.esp@free.fr>
Subject: Re: IRQF_SAMPLE_RANDOM question...
Date: Wed, 8 Apr 2009 23:53:30 +0200
Message-ID: <2c6601c9b894$756e4000$f9b5a8c0@pii350>
References: <200904061430.26276.rgetz@blackfin.uclinux.org> <1239116251.14392.133.camel@calx> <a24804730904071439g4cc1779bi1ebaf814d370708c@mail.gmail.com> <200904071830.38081.rgetz@blackfin.uclinux.org>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: "Matt Mackall" <mpm@selenic.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>
To: "Robin Getz" <rgetz@blackfin.uclinux.org>,
	"Chris Peterson" <cpeterso@cpeterso.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtpfb1-g21.free.fr ([212.27.42.9]:33983 "EHLO
	smtpfb1-g21.free.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752517AbZDHV5c (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Apr 2009 17:57:32 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


----- Original Message ----- 
From: "Robin Getz" <rgetz@blackfin.uclinux.org>
To: "Chris Peterson" <cpeterso@cpeterso.com>
Cc: "Matt Mackall" <mpm@selenic.com>; <netdev@vger.kernel.org>;
<linux-kernel@vger.kernel.org>
Sent: Wednesday, April 08, 2009 12:30 AM
Subject: Re: IRQF_SAMPLE_RANDOM question...


>
> on embedded and server - it is likely most of ps (except load) will be
pretty
> stable - even vmstat - might be on more stable than you think on
embedded -
> which starts processes, allocates memory, and then just runs forever.....
>
After the topic on that subject in May, I find clrngd
http://ipsec.pl/files/ipsec/clrngd-1.0.3.tar.gz

That's a small C program that feed /dev/random
Readme say :
"This daemon attempts to collect real randomness from fluctuations of
high-frequency clocks on a PC's mainboard. The basic assumption is that
mainboard and CPU are clocked by two separate physical clocks."

Shortly tested, look to work for me.
How large is this basic assumption true, on x86, on other arch?

Gilles

