From: "Bernard, f6bvp" <f6bvp@free.fr>
Subject: Re: ax25 rose Re: kernel panic linux-2.6.27-rc7
Date: Sun, 05 Oct 2008 17:40:12 +0200
Message-ID: <1223221212.18094.4.camel@f6bvp-5>
References: <20081002194845.GB2664@ami.dom.local>
	 <20081003073418.GA5235@ff.dom.local> <20081003074351.GB5235@ff.dom.local>
	 <1223145027.23358.20.camel@f6bvp-5> <20081004191114.GA15152@ami.dom.local>
	 <20081004200939.GB15152@ami.dom.local>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-BBas9fs3pwWlCj97muGW"
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Ralf Baechle DL5RB <ralf@linux-mips.org>,
	David Miller <davem@davemloft.net>
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp6-g19.free.fr ([212.27.42.36]:55818 "EHLO smtp6-g19.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754014AbYJEPjQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 5 Oct 2008 11:39:16 -0400
In-Reply-To: <20081004200939.GB15152@ami.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-BBas9fs3pwWlCj97muGW
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit

With kernel-2.6.27-rc7 and ypur patches including netrom one I observed
three events via netconsole.
I think that they were triggered by NetRom activity I exercized on
purpose.
See attached documents.

Bernard

Le samedi 04 octobre 2008 à 22:09 +0200, Jarek Poplawski a écrit :
> On Sat, Oct 04, 2008 at 09:11:14PM +0200, Jarek Poplawski wrote:
> ...
> > BTW, I think there is an additional, not serious problem with freeing
> > unorphaned sockets by netrom (as seen in your debugging logs with non
> > zero in the 2-nd, and 6 in the 3-rd column). So, it would be nice to
> > check if my #4 patch could help for this. (You need then 2.6.27-rc
> > with patches #1(debugging), #3, #4 as signed in my previous message,
> > and of course above mentioned one reverted).
> 
> BTW, could you please test it with and without the #4 (af_netrom) patch?
> 
> Jarek P.
> 

--=-BBas9fs3pwWlCj97muGW
Content-Disposition: attachment; filename=2.6.27-rc7_trylock_failure.txt
Content-Type: text/plain; name=2.6.27-rc7_trylock_failure.txt; charset=utf-8
Content-Transfer-Encoding: 8bit

﻿AX25_DBG: c4056cc8, 00000000, 1, 1, 0
AX25_DBG: c64db008, 00000000, 1, 0, 0
AX25_DBG: c4056998, 00000000, 1, 0, 0
AX25_DBG: c64db008, 00000000, 1, 1, 0
AX25_DBG: c4056998, 00000000, 1, 0, 0
AX25_DBG: c64db008, 00000000, 1, 1, 0
AX25_DBG: c4056998, 00000000, 1, 0, 0
AX25_DBG: c6457338, 00000000, 1, 1, 0
AX25_DBG: c4056cc8, 00000000, 1, 1, 0
AX25_DBG: c64db008, 00000000, 1, 1, 0
AX25_DBG: c4056cc8, 00000000, 1, 0, 0
AX25_DBG: c64db008, 00000000, 1, 1, 0
AX25_DBG: c4056cc8, 00000000, 1, 0, 0
AX25_DBG: c64db008, 00000000, 1, 1, 0
AX25_DBG: c4056cc8, 00000000, 1, 0, 0
AX25_DBG: c64db008, 00000000, 1, 1, 0
AX25_DBG: c4056cc8, 00000000, 1, 0, 0
AX25_DBG: c64db008, 00000000, 1, 1, 0
AX25_DBG: c4056cc8, 00000000, 1, 0, 0
AX25_DBG: c64db008, 00000000, 1, 1, 0
AX25_DBG: c4056cc8, 00000000, 1, 0, 0
AX25_DBG: c64db008, 00000000, 1, 1, 0
AX25_DBG: c6457338, 00000000, 1, 0, 0
AX25_DBG: c4056cc8, 00000000, 1, 1, 0
AX25_DBG: c6457338, 00000000, 1, 0, 0
AX25_DBG: c4056cc8, 00000000, 1, 1, 0
AX25_DBG: c4056cc8, 00000000, 1, 0, 0
AX25_DBG: c64db008, 00000000, 1, 1, 0
AX25_DBG: c64db008, 00000000, 1, 2, 0
AX25_DBG: c64db008, 00000000, 1, 2, 0
AX25_DBG: c64db008, 00000000, 1, 2, 0
AX25_DBG: c64db008, 00000000, 1, 2, 0
AX25_DBG: c4056cc8, 00000000, 1, 0, 0
AX25_DBG: c64db008, 00000000, 1, 1, 0
AX25_DBG: c4056cc8, 00000000, 1, 0, 0
AX25_DBG: c64db008, 00000000, 1, 1, 0
AX25_DBG: c64db008, 00000000, 1, 2, 0
AX25_DBG: c64db008, 00000000, 1, 2, 0
AX25_DBG: c64db008, 00000000, 1, 2, 0
AX25_DBG: c64db008, 00000000, 1, 2, 0
AX25_DBG: c4056cc8, 00000000, 1, 0, 0
AX25_DBG: c4056cc8, 00000000, 1, 2, 0
AX25_DBG: c4056cc8, 00000000, 1, 2, 0
AX25_DBG: c64db008, 00000000, 1, 1, 0
AX25_DBG: c4056cc8, 00000000, 1, 0, 0
AX25_DBG: c4056cc8, 00000000, 1, 2, 0
AX25_DBG: c4056cc8, 00000000, 1, 2, 0
AX25_DBG: c6457338, 00000000, 1, 0, 0
AX25_DBG: c64db008, 00000000, 1, 1, 0
AX25_DBG: c4056cc8, 00000000, 1, 1, 0
AX25_DBG: c64db008, 00000000, 1, 0, 0
AX25_DBG: c4056cc8, 00000000, 1, 1, 0
AX25_DBG: c4056cc8, 00000000, 1, 2, 0
AX25_DBG: c4056cc8, 00000000, 1, 2, 0
AX25_DBG: c4056cc8, 00000000, 1, 2, 0
AX25_DBG: c4056cc8, 00000000, 1, 2, 0
AX25_DBG: c6bbf668, 00000000, 2, 2, 17
AX25_DBG: c6457338, 00000000, 1, 0, 0
AX25_DBG: c64db008, 00000000, 1, 1, 0
AX25_DBG: c6457338, 00000000, 1, 0, 0
AX25_DBG: c64db008, 00000000, 1, 1, 0
AX25_DBG: c6457338, 00000000, 1, 0, 0
AX25_DBG: c64db008, 00000000, 1, 1, 0
AX25_DBG: c6457338, 00000000, 1, 0, 0
AX25_DBG: c64db008, 00000000, 1, 1, 0
AX25_DBG: c6457338, 00000000, 1, 0, 0
AX25_DBG: c64db008, 00000000, 1, 1, 0
AX25_DBG: c6457338, 00000000, 1, 0, 0
AX25_DBG: c64db008, 00000000, 1, 1, 0
AX25_DBG: c64db008, 00000000, 1, 2, 0
AX25_DBG: c64db008, 00000000, 1, 2, 0
AX25_DBG: c6bbf668, 00000000, 2, 2, 17
AX25_DBG: c6457338, 00000000, 1, 0, 0
AX25_DBG: c64db008, 00000000, 1, 1, 0
AX25_DBG: c6457338, 00000000, 1, 0, 0
AX25_DBG: c64db008, 00000000, 1, 1, 0
AX25_DBG: c6457338, 00000000, 1, 0, 0
AX25_DBG: c64db008, 00000000, 1, 1, 0
AX25_DBG: c6457338, 00000000, 1, 0, 0
AX25_DBG: c64db008, 00000000, 1, 1, 0
AX25_DBG: c6457338, 00000000, 1, 0, 0
AX25_DBG: c64db008, 00000000, 1, 1, 0
AX25_DBG: c6457338, 00000000, 1, 0, 0
AX25_DBG: c64db008, 00000000, 1, 1, 0
AX25_DBG: c64db008, 00000000, 1, 2, 0
AX25_DBG: c64db008, 00000000, 1, 2, 0
AX25_DBG: c6bbf668, 00000000, 2, 2, 17
AX25_DBG: c6796c38, 00000000, 2, 1, 6
AX25_DBG: c669e690, 00000000, 10, 1, 6
AX25_DBG: c64db008, 00000000, 1, 1, 0
AX25_DBG: c6bbf350, 00000000, 2, 2, 17
AX25_DBG: c6bbf350, 00000000, 2, 2, 17
AX25_DBG: c6bbf350, 00000000, 2, 2, 17
AX25_DBG: c6bbf038, 00000000, 2, 2, 17
AX25_DBG: c6796648, 00000000, 2, 1, 6
AX25_DBG: c669ece8, 00000000, 10, 1, 6
AX25_DBG: c64db008, 00000000, 1, 1, 0
AX25_DBG: c6bbf038, 00000000, 2, 2, 17
AX25_DBG: c6bbf038, 00000000, 2, 2, 17
AX25_DBG: c6bbf038, 00000000, 2, 2, 17
AX25_DBG: c64db008, 00000000, 1, 2, 0
AX25_DBG: c6bbf668, 00000000, 2, 2, 17
AX25_DBG: c647e058, 00000000, 10, 2, 17
AX25_DBG: c67cc0e0, 00000000, 3, 2, 240
AX25_DBG: c6457338, 00000000, 1, 0, 0
AX25_DBG: c64db008, 00000000, 1, 1, 0
AX25_DBG: c6457338, 00000000, 1, 0, 0
AX25_DBG: c64db008, 00000000, 1, 1, 0
AX25_DBG: c6457338, 00000000, 1, 0, 0
AX25_DBG: c64db008, 00000000, 1, 1, 0
AX25_DBG: c6457338, 00000000, 1, 0, 0
AX25_DBG: c64db008, 00000000, 1, 1, 0
AX25_DBG: c64db008, 00000000, 1, 2, 0
AX25_DBG: c64db008, 00000000, 1, 2, 0
AX25_DBG: c6bbf668, 00000000, 2, 2, 17
AX25_DBG: c4056998, 00000000, 1, 0, 0
AX25_DBG: c6457338, 00000000, 1, 1, 0
AX25_DBG: c4056998, 00000000, 1, 0, 0
AX25_DBG: c6457338, 00000000, 1, 1, 0
AX25_DBG: c6bbf668, 00000000, 2, 2, 17
AX25_DBG: c4056998, 00000000, 1, 2, 0
AX25_DBG: c4056998, 00000000, 1, 2, 0
AX25_DBG: c4056668, 00000000, 1, 0, 0
AX25_DBG: c4056998, 00000000, 1, 1, 0
AX25_DBG: c4056668, 00000000, 1, 0, 0
AX25_DBG: c4056998, 00000000, 1, 1, 0
AX25_DBG: c4056668, 00000000, 1, 0, 0
AX25_DBG: c4056998, 00000000, 1, 1, 0
AX25_DBG: c4056668, 00000000, 1, 0, 0
AX25_DBG: c4056998, 00000000, 1, 1, 0
AX25_DBG: c4056668, 00000000, 1, 0, 0
AX25_DBG: c4056998, 00000000, 1, 1, 0
AX25_DBG: c4056668, 00000000, 1, 0, 0
AX25_DBG: c4056998, 00000000, 1, 1, 0
AX25_DBG: c4056668, 00000000, 1, 0, 0
AX25_DBG: c4056998, 00000000, 1, 1, 0
AX25_DBG: c4056668, 00000000, 1, 0, 0
AX25_DBG: c4056998, 00000000, 1, 1, 0
AX25_DBG: c4056668, 00000000, 1, 0, 0
AX25_DBG: c4056998, 00000000, 1, 1, 0
AX25_DBG: c4056668, 00000000, 1, 0, 0
AX25_DBG: c4056008, 00000000, 1, 0, 0
AX25_DBG: c4056668, 00000000, 1, 1, 0
AX25_DBG: c4056008, 00000000, 1, 0, 0
AX25_DBG: c4056668, 00000000, 1, 1, 0
AX25_DBG: c4056008, 00000000, 1, 0, 0
AX25_DBG: c4056668, 00000000, 1, 1, 0
AX25_DBG: c4056008, 00000000, 1, 0, 0
AX25_DBG: c4056668, 00000000, 1, 1, 0
AX25_DBG: c4056008, 00000000, 1, 0, 0
AX25_DBG: c4056338, 00000000, 1, 0, 0
AX25_DBG: c4056008, 00000000, 1, 1, 0
AX25_DBG: c4056338, 00000000, 1, 0, 0
AX25_DBG: c4056008, 00000000, 1, 1, 0
AX25_DBG: c4056998, 00000000, 1, 1, 0
AX25_DBG: c4056668, 00000000, 1, 1, 0
AX25_DBG: c4056998, 00000000, 1, 0, 0
AX25_DBG: c4056668, 00000000, 1, 1, 0
AX25_DBG: c4056668, 00000000, 1, 2, 0
AX25_DBG: c4056668, 00000000, 1, 2, 0
AX25_DBG: c4056998, 00000000, 1, 0, 0
AX25_DBG: c4056668, 00000000, 1, 1, 0
AX25_DBG: c4056998, 00000000, 1, 0, 0
AX25_DBG: c4056668, 00000000, 1, 1, 0
AX25_DBG: c4056998, 00000000, 1, 0, 0
AX25_DBG: c4056668, 00000000, 1, 1, 0
AX25_DBG: c4056998, 00000000, 1, 0, 0
AX25_DBG: c4056668, 00000000, 1, 1, 0
AX25_DBG: c4056998, 00000000, 1, 0, 0
AX25_DBG: c4056668, 00000000, 1, 1, 0
AX25_DBG: c4056998, 00000000, 1, 0, 0
AX25_DBG: c4056668, 00000000, 1, 1, 0
AX25_DBG: c4056668, 00000000, 1, 2, 0
AX25_DBG: c4056668, 00000000, 1, 2, 0
AX25_DBG: c4056668, 00000000, 1, 2, 0
AX25_DBG: c4056668, 00000000, 1, 2, 0
AX25_DBG: c4056668, 00000000, 1, 2, 0
AX25_DBG: c4056668, 00000000, 1, 2, 0
AX25_DBG: c4056668, 00000000, 1, 2, 0
AX25_DBG: c6bbf038, 00000000, 2, 2, 17
AX25_DBG: c647e058, 00000000, 10, 2, 17
AX25_DBG: c40419b0, 00000000, 3, 2, 240
AX25_DBG: c4000930, 00000000, 6, 5, 0
AX25_DBG: c4056668, 00000000, 1, 2, 0
AX25_DBG: c6bbf038, 00000000, 2, 2, 17
AX25_DBG: c647e058, 00000000, 10, 2, 17
AX25_DBG: c4040120, 00000000, 3, 2, 240
AX25_DBG: c67030a0, 00000000, 6, 5, 0
AX25_DBG: c4056668, 00000000, 1, 2, 0
AX25_DBG: c6bbf038, 00000000, 2, 2, 17
AX25_DBG: c647e058, 00000000, 10, 2, 17
AX25_DBG: c4000930, 00000000, 3, 2, 240
AX25_DBG: c40419b0, 00000000, 6, 5, 0
AX25_DBG: c6bbf038, 00000000, 2, 2, 17
AX25_DBG: c6bbf038, 00000000, 2, 2, 17
AX25_DBG: c6bbf038, 00000000, 2, 2, 17
AX25_DBG: c6bbf038, 00000000, 2, 2, 17
AX25_DBG: c6bbf038, 00000000, 2, 2, 17
AX25_DBG: c6bbf038, 00000000, 2, 2, 17
AX25_DBG: c6bbf038, 00000000, 2, 2, 17
AX25_DBG: c40419b0, 00000000, 6, 5, 0
AX25_DBG: c6bbf038, 00000000, 2, 2, 17
AX25_DBG: c4000930, 00000000, 6, 5, 0
AX25_DBG: c6bbf038, 00000000, 2, 2, 17
AX25_DBG: c67030a0, 00000000, 6, 5, 0
AX25_DBG: c6bbf038, 00000000, 2, 2, 17
AX25_DBG: c6bbf038, 00000000, 2, 2, 17
AX25_DBG: c4056998, 00000000, 1, 2, 0
AX25_DBG: c6bbf038, 00000000, 2, 2, 17
AX25_DBG: c647e058, 00000000, 10, 2, 17
AX25_DBG: c67030a0, 00000000, 3, 2, 240
AX25_DBG: c4040d68, 00000000, 6, 5, 0
AX25_DBG: c4056998, 00000000, 1, 2, 0
AX25_DBG: c6bbf038, 00000000, 2, 2, 17
AX25_DBG: c647e058, 00000000, 10, 2, 17
AX25_DBG: c40419b0, 00000000, 3, 2, 240
AX25_DBG: c4040120, 00000000, 6, 5, 0
AX25_DBG: c4056998, 00000000, 1, 2, 0
AX25_DBG: c6bbf038, 00000000, 2, 2, 17
AX25_DBG: c647e058, 00000000, 10, 2, 17
AX25_DBG: c4040d68, 00000000, 3, 2, 240
AX25_DBG: c67030a0, 00000000, 6, 5, 0
AX25_DBG: c6bbf350, 00000000, 2, 2, 17
AX25_DBG: c40874a0, 00000000, 11, 5, 0
AX25_DBG: c6bbf350, 00000000, 2, 2, 17
AX25_DBG: c6bbf350, 00000000, 2, 2, 17
AX25_DBG: c6bbf350, 00000000, 2, 2, 17
AX25_DBG: c6bbf350, 00000000, 2, 2, 17
AX25_DBG: c6bbf350, 00000000, 2, 2, 17
AX25_DBG: c6bbf350, 00000000, 2, 2, 17
AX25_DBG: c6bbf350, 00000000, 2, 2, 17
AX25_DBG: c6bbf350, 00000000, 2, 2, 17
AX25_DBG: c6bbf350, 00000000, 2, 2, 17
AX25_DBG: c6bbf350, 00000000, 2, 2, 17
AX25_DBG: c6bbf350, 00000000, 2, 2, 17
AX25_DBG: c6bbf350, 00000000, 2, 2, 17
AX25_DBG: c6bbf350, 00000000, 2, 2, 17
AX25_DBG: c6bbf350, 00000000, 2, 2, 17
AX25_DBG: c6bbf350, 00000000, 2, 2, 17
AX25_DBG: c6bbf350, 00000000, 2, 2, 17
AX25_DBG: c6bbf350, 00000000, 2, 2, 17
AX25_DBG: c4000d48, 00000000, 3, 2, 207
AX25_DBG: c6bbf038, 00000000, 2, 2, 17
AX25_DBG: c6bbf038, 00000000, 2, 2, 17
AX25_DBG: c6bbf038, 00000000, 2, 2, 17
AX25_DBG: c4000d48, 00000000, 3, 2, 207
AX25_DBG: c67eadc8, 00000000, 17, 10, 0
AX25_DBG: c40bf7a0, 00000000, 11, 5, 0
AX25_DBG: c40eb618, 00000000, 3, 5, 240
AX25_DBG: c40eade8, 00000000, 3, 5, 240
AX25_DBG: c40ea5b8, 00000000, 3, 5, 240
AX25_DBG: c40d1a50, 00000000, 3, 5, 240
AX25_DBG: c6796c38, 00000000, 2, 1, 6
AX25_DBG: c40d1220, 00000000, 6, 5, 0
AX25_DBG: c6bbf350, 00000000, 2, 2, 17
AX25_DBG: c6bbf350, 00000000, 2, 2, 17
AX25_DBG: c6bbf350, 00000000, 2, 2, 17
AX25_DBG: c4000d48, 00000000, 3, 2, 207
AX25_DBG: c67e9620, 00000000, 11, 5, 0
AX25_DBG: c40945d0, 00000000, 11, 5, 0
AX25_DBG: c6bbf350, 00000000, 2, 2, 17
AX25_DBG: c6bbf350, 00000000, 2, 2, 17
AX25_DBG: c6bbf350, 00000000, 2, 2, 17
AX25_DBG: c67ea180, 00000000, 3, 2, 207
AX25_DBG: c67ea180, 00000000, 6, 5, 0
AX25_DBG: c4000d48, 00000000, 3, 5, 240
AX25_DBG: c40bce28, 00000000, 11, 5, 0
AX25_DBG: c40e2cc8, 00000000, 1, 0, 0
AX25_DBG: c4056998, 00000000, 1, 1, 0
AX25_DBG: c40e2cc8, 00000000, 1, 0, 0
AX25_DBG: c4056998, 00000000, 1, 1, 0
AX25_DBG: c6750cc8, 00000000, 1, 0, 0
AX25_DBG: c4056998, 00000000, 1, 1, 0
AX25_DBG: c6750cc8, 00000000, 1, 0, 0
AX25_DBG: c4056998, 00000000, 1, 1, 0
AX25_DBG: c4040120, 00000000, 16, 3, 0
AX25_DBG: c6bbf038, 00000000, 2, 2, 17
AX25_DBG: c6bbf038, 00000000, 2, 2, 17
AX25_DBG: c6bbf038, 00000000, 2, 2, 17
AX25_DBG: c6bbf038, 00000000, 2, 2, 17
AX25_DBG: c6bbf038, 00000000, 2, 2, 17
AX25_DBG: c6bbf038, 00000000, 2, 2, 17
AX25_DBG: c6bbf038, 00000000, 2, 2, 17
AX25_DBG: c6bbf038, 00000000, 2, 2, 17
AX25_DBG: c4040120, 00000000, 16, 3, 0
AX25_DBG: c6bbf038, 00000000, 2, 2, 17
AX25_DBG: c6bbf038, 00000000, 2, 2, 17
AX25_DBG: c6bbf038, 00000000, 2, 2, 17
AX25_DBG: c6bbf038, 00000000, 2, 2, 17
AX25_DBG: c6bbf038, 00000000, 2, 2, 17
AX25_DBG: c6bbf038, 00000000, 2, 2, 17
AX25_DBG: c6bbf038, 00000000, 2, 2, 17
AX25_DBG: c6bbf038, 00000000, 2, 2, 17
AX25_DBG: c4040120, 00000000, 16, 3, 0
AX25_DBG: c6bbf038, 00000000, 2, 2, 17
AX25_DBG: c6bbf038, 00000000, 2, 2, 17
AX25_DBG: c6bbf038, 00000000, 2, 2, 17
AX25_DBG: c6bbf038, 00000000, 2, 2, 17
AX25_DBG: c6bbf038, 00000000, 2, 2, 17
AX25_DBG: c6bbf038, 00000000, 2, 2, 17
AX25_DBG: c6bbf038, 00000000, 2, 2, 17
AX25_DBG: c6bbf038, 00000000, 2, 2, 17
AX25_DBG: c4019cc8, 00000000, 1, 0, 0
AX25_DBG: c4056998, 00000000, 1, 1, 0
AX25_DBG: c4019cc8, 00000000, 1, 0, 0
AX25_DBG: c4056998, 00000000, 1, 1, 0
AX25_DBG: c40b9838, 00000000, 2, 1, 6
AX25_DBG: c6bbf350, 00000000, 2, 2, 17
AX25_DBG: c408bcc8, 00000000, 1, 0, 0
AX25_DBG: c4056998, 00000000, 1, 1, 0
AX25_DBG: c408bcc8, 00000000, 1, 0, 0
AX25_DBG: c4056998, 00000000, 1, 1, 0
AX25_DBG: c6bbf350, 00000000, 2, 2, 17
AX25_DBG: c6bbf350, 00000000, 2, 2, 17
AX25_DBG: c40ccf28, 00000000, 11, 5, 0
AX25_DBG: c40bd0e0, 00000000, 11, 5, 0
AX25_DBG: c40cd740, 00000000, 11, 5, 0
AX25_DBG: c40c4ea8, 00000000, 11, 5, 0
AX25_DBG: c40ccf28, 00000000, 11, 5, 0
AX25_DBG: c40c4ea8, 00000000, 11, 5, 0
AX25_DBG: c40c76e0, 00000000, 11, 5, 0
AX25_DBG: c4049100, 00000000, 11, 5, 0
AX25_DBG: c40eb200, 00000000, 16, 3, 9
AX25_DBG: c7bb4cc8, 00000000, 1, 0, 0
AX25_DBG: c4056998, 00000000, 1, 1, 0
AX25_DBG: c7bb4cc8, 00000000, 1, 0, 0
AX25_DBG: c4056998, 00000000, 1, 1, 0
AX25_DBG: c40eb200, 00000000, 16, 3, 9
AX25_DBG: c40eb200, 00000000, 16, 3, 9
AX25_DBG: c4056998, 00000000, 1, 2, 0
AX25_DBG: c40eb200, 00000000, 16, 3, 9
AX25_DBG: c40eb200, 00000000, 16, 3, 9
AX25_DBG: c4056998, 00000000, 1, 2, 0
AX25_DBG: c6bbf350, 00000000, 2, 2, 17
AX25_DBG: c40eb200, 00000000, 16, 3, 0
AX25_DBG: c6bbf350, 00000000, 2, 2, 17
AX25_DBG: c6bbf350, 00000000, 2, 2, 17
AX25_DBG: c6bbf350, 00000000, 2, 2, 17
AX25_DBG: c6bbf350, 00000000, 2, 2, 17
AX25_DBG: c6bbf350, 00000000, 2, 2, 17
AX25_DBG: c6bbf350, 00000000, 2, 2, 17
AX25_DBG: c6bbf350, 00000000, 2, 2, 17
AX25_DBG: c6bbf350, 00000000, 2, 2, 17
AX25_DBG: c40eb200, 00000000, 16, 3, 0
AX25_DBG: c6bbf350, 00000000, 2, 2, 17
AX25_DBG: c6bbf350, 00000000, 2, 2, 17
AX25_DBG: c6bbf350, 00000000, 2, 2, 17
AX25_DBG: c6bbf350, 00000000, 2, 2, 17
AX25_DBG: c6bbf350, 00000000, 2, 2, 17
AX25_DBG: c6bbf350, 00000000, 2, 2, 17
AX25_DBG: c6bbf350, 00000000, 2, 2, 17
AX25_DBG: c6bbf350, 00000000, 2, 2, 17
AX25_DBG: c40eb200, 00000000, 16, 3, 0
AX25_DBG: c6bbf350, 00000000, 2, 2, 17
AX25_DBG: c6bbf350, 00000000, 2, 2, 17
AX25_DBG: c6bbf350, 00000000, 2, 2, 17
AX25_DBG: c6bbf350, 00000000, 2, 2, 17
AX25_DBG: c6bbf350, 00000000, 2, 2, 17
AX25_DBG: c6bbf350, 00000000, 2, 2, 17
AX25_DBG: c6bbf350, 00000000, 2, 2, 17
AX25_DBG: c6bbf350, 00000000, 2, 2, 17
AX25_DBG: c40ef858, 00000000, 2, 1, 6
AX25_DBG: c40ef878, 00000000, 2, 1, 6
AX25_DBG: c40ee0b8, 00000000, 2, 1, 6
AX25_DBG: c40c76e0, 00000000, 11, 5, 0
ROSE: rose_kill_by_neigh() - neighbour->use-- could be < 0
ROSE: rose_kill_by_neigh() - neighbour->use-- could be < 0
ROSE: rose_kill_by_neigh() - neighbour->use-- could be < 0
ROSE: rose_kill_by_neigh() - neighbour->use-- could be < 0
ROSE: rose_kill_by_neigh() - neighbour->use-- could be < 0
ROSE: rose_kill_by_neigh() - neighbour->use-- could be < 0
ROSE: rose_kill_by_neigh() - neighbour->use-- could be < 0
AX25_DBG: c67e8e08, 00000000, 11, 5, 0
AX25_DBG: c67e8e08, 00000000, 11, 5, 0
AX25_DBG: c6bbf350, 00000000, 2, 2, 17
AX25_DBG: c6bbf350, 00000000, 2, 2, 17
AX25_DBG: c7bb4cb8, 00000000, 2, 2, 17
AX25_DBG: c409bcc8, 00000000, 1, 0, 0
AX25_DBG: c4056998, 00000000, 1, 1, 0
AX25_DBG: c409bcc8, 00000000, 1, 0, 0
AX25_DBG: c4056998, 00000000, 1, 1, 0
AX25_DBG: c7bb4cb8, 00000000, 2, 2, 17
AX25_DBG: c7bb4cb8, 00000000, 2, 2, 17
AX25_DBG: c6bbf350, 00000000, 2, 2, 17
BUG: spinlock trylock failure on UP on CPU#0, fpacstat/3752
 lock: c7b58d44, .magic: dead4ead, .owner: fpacstat/3752, .owner_cpu: 0
Pid: 3752, comm: fpacstat Not tainted 2.6.27-rc7 #3
 [<c01e9a4a>] spin_bug+0x8a/0xe0
 [<c01e9ac5>] _raw_spin_trylock+0x25/0x50
 [<c02bfbde>] _spin_trylock+0xe/0x50
 [<c0265562>] netpoll_send_skb+0x132/0x190
 [<c0265a5d>] netpoll_send_udp+0x1ed/0x200
 [<c8a7217c>] write_msg+0x9c/0xe0 [netconsole]
 [<c8a720e0>] ? write_msg+0x0/0xe0 [netconsole]
 [<c011d5e7>] __call_console_drivers+0x47/0x60
 [<c011d679>] _call_console_drivers+0x79/0x90
 [<c011da50>] release_console_sem+0xc0/0x1e0
 [<c011e000>] vprintk+0x290/0x3c0
 [<c014023c>] ? __lock_acquire+0x37c/0x9b0
 [<c013b8eb>] ? trace_hardirqs_off+0xb/0x10
 [<c011e14b>] printk+0x1b/0x20
 [<c024e5ac>] sk_free+0x3c/0x130
 [<c02500cd>] sock_wfree+0x2d/0x40
 [<c02524ba>] skb_release_all+0x3a/0x90
 [<c0251c5b>] __kfree_skb+0xb/0x90
 [<c0251cf9>] kfree_skb+0x19/0x30
 [<c89e1f74>] ei_start_xmit+0x164/0x330 [8390]
 [<c8ac9580>] ? packet_rcv_spkt+0x0/0x110 [af_packet]
 [<c0257de0>] dev_hard_start_xmit+0x210/0x280
 [<c0257c1a>] ? dev_hard_start_xmit+0x4a/0x280
 [<c0267fed>] __qdisc_run+0x16d/0x1e0
 [<c025a708>] dev_queue_xmit+0x1c8/0x4d0
 [<c025a57b>] ? dev_queue_xmit+0x3b/0x4d0
 [<c0121e0b>] ? local_bh_enable_ip+0x6b/0xb0
 [<c0260559>] neigh_resolve_output+0xe9/0x290
 [<c0121e0b>] ? local_bh_enable_ip+0x6b/0xb0
 [<c025e8ac>] neigh_update+0x23c/0x420
 [<c0121e0b>] ? local_bh_enable_ip+0x6b/0xb0
 [<c02676c0>] ? eth_header_cache_update+0x0/0x20
 [<c0294f6f>] arp_process+0x2ff/0x670
 [<c0294c70>] ? arp_process+0x0/0x670
 [<c026cd56>] ? nf_hook_slow+0xe6/0x100
 [<c0294c70>] ? arp_process+0x0/0x670
 [<c02953a9>] arp_rcv+0xc9/0x120
 [<c0294c70>] ? arp_process+0x0/0x670
 [<c02952e0>] ? arp_rcv+0x0/0x120
 [<c0257742>] netif_receive_skb+0x232/0x2e0
 [<c02575ea>] ? netif_receive_skb+0xda/0x2e0
 [<c025a163>] process_backlog+0x63/0xc0
 [<c02599ee>] net_rx_action+0x13e/0x1d0
 [<c0259910>] ? net_rx_action+0x60/0x1d0
 [<c0121ce5>] __do_softirq+0x55/0xc0
 [<c0121d96>] do_softirq+0x46/0x50
 [<c0122107>] irq_exit+0x57/0x70
 [<c010639f>] do_IRQ+0x4f/0xa0
 [<c01e5d14>] ? trace_hardirqs_off_thunk+0xc/0x18
 [<c01045e4>] common_interrupt+0x28/0x30
 [<c013007b>] ? sys_timer_delete+0x10b/0x110
 [<c0140bfc>] ? lock_release+0xac/0x1c0
 [<c017e2bf>] do_select+0x13f/0x5a0
 [<c017e180>] ? do_select+0x0/0x5a0
 [<c017ec80>] ? __pollwait+0x0/0xd0
 [<c0117fa0>] ? default_wake_function+0x0/0x10
 [<c014023c>] ? __lock_acquire+0x37c/0x9b0
 [<c013f0dc>] ? validate_chain+0xbc/0xea0
 [<c013b8eb>] ? trace_hardirqs_off+0xb/0x10
 [<c014023c>] ? __lock_acquire+0x37c/0x9b0
 [<c016d116>] ? poison_obj+0x26/0x50
 [<c016d116>] ? poison_obj+0x26/0x50
 [<c016d3be>] ? cache_free_debugcheck+0xce/0x230
 [<c016d3be>] ? cache_free_debugcheck+0xce/0x230
 [<c013ea4f>] ? debug_check_no_locks_freed+0x6f/0x120
 [<c013e94d>] ? trace_hardirqs_on_caller+0xbd/0x140
 [<c013e9db>] ? trace_hardirqs_on+0xb/0x10
 [<c013e94d>] ? trace_hardirqs_on_caller+0xbd/0x140
 [<c013e9db>] ? trace_hardirqs_on+0xb/0x10
 [<c014023c>] ? __lock_acquire+0x37c/0x9b0
 [<c013b8eb>] ? trace_hardirqs_off+0xb/0x10
 [<c01e6146>] ? copy_from_user+0x46/0x80
 [<c017e90a>] core_sys_select+0x1ea/0x330
 [<c017e74d>] ? core_sys_select+0x2d/0x330
 [<c01e6408>] ? copy_to_user+0x48/0x60
 [<c024c980>] ? move_addr_to_user+0x60/0x70
 [<c024cbf1>] ? sys_recvfrom+0xa1/0xd0
 [<c013b8eb>] ? trace_hardirqs_off+0xb/0x10
 [<c013b970>] ? lock_release_holdtime+0x80/0xb0
 [<c017ee1b>] sys_select+0xcb/0x190
 [<c01e5d04>] ? trace_hardirqs_on_thunk+0xc/0x10
 [<c0103bbd>] sysenter_do_call+0x12/0x35
 =======================
AX25_DBG: c40ef898, 00000000, 2, 1, 6
AX25_DBG: c40ef8b8, 00000000, 2, 1, 6
AX25_DBG: c6bbf350, 00000000, 2, 2, 17
AX25_DBG: c40ef2c8, 00000000, 2, 1, 6
AX25_DBG: c40e3cc8, 00000000, 1, 0, 0
AX25_DBG: c4056998, 00000000, 1, 1, 0
AX25_DBG: c40e3cc8, 00000000, 1, 0, 0
AX25_DBG: c4056998, 00000000, 1, 1, 0
AX25_DBG: c40e3998, 00000000, 1, 0, 0
AX25_DBG: c40e3cc8, 00000000, 1, 1, 0
AX25_DBG: c40e3998, 00000000, 1, 0, 0
AX25_DBG: c40e3cc8, 00000000, 1, 1, 0
AX25_DBG: c6bbf350, 00000000, 2, 2, 17
AX25_DBG: c6bbf350, 00000000, 2, 2, 17
AX25_DBG: c40ef2c8, 00000000, 2, 1, 6
AX25_DBG: c40ef8b8, 00000000, 2, 1, 6
AX25_DBG: c40eecd8, 00000000, 2, 1, 6
AX25_DBG: c67e8e08, 00000000, 11, 5, 0
AX25_DBG: c40c76e0, 00000000, 11, 5, 0
AX25_DBG: c67e8e08, 00000000, 11, 5, 0
AX25_DBG: c67e8e08, 00000000, 11, 5, 0
AX25_DBG: c6bbf350, 00000000, 2, 2, 17
AX25_DBG: c40ee0f8, 00000000, 2, 1, 6
AX25_DBG: c67e8e08, 00000000, 11, 5, 0
AX25_DBG: c6bbf350, 00000000, 2, 2, 17
AX25_DBG: c40d05d8, 00000000, 16, 3, 0
AX25_DBG: c6bbf350, 00000000, 2, 2, 17
AX25_DBG: c6bbf350, 00000000, 2, 2, 17


--=-BBas9fs3pwWlCj97muGW
Content-Disposition: attachment; filename=kernel-panic-2.6.27-rc7.txt
Content-Type: text/plain; name=kernel-panic-2.6.27-rc7.txt; charset=utf-8
Content-Transfer-Encoding: 8bit

﻿------------------------------
Sun Oct  5 14:08:13 CEST 2008
------------------------------
AX25_DBG: c7bb4058, 00000000, 2, 2, 17
AX25_DBG: c40ccf28, 00000000, 11, 5, 0
AX25_DBG: c40e2080, 00000000, 16, 3, 9
AX25_DBG: c4120998, 00000000, 1, 0, 0
AX25_DBG: c4120cc8, 00000000, 1, 1, 0
AX25_DBG: c4120998, 00000000, 1, 0, 0
AX25_DBG: c4120cc8, 00000000, 1, 1, 0
AX25_DBG: c40e2080, 00000000, 16, 3, 9
AX25_DBG: c40e2080, 00000000, 16, 3, 9
AX25_DBG: c4120cc8, 00000000, 1, 2, 0
AX25_DBG: c40e2080, 00000000, 16, 3, 9
AX25_DBG: c40e2080, 00000000, 16, 3, 9
AX25_DBG: c4120cc8, 00000000, 1, 2, 0
AX25_DBG: c40c4ea8, 00000000, 11, 5, 0
AX25_DBG: c4135300, 00000000, 11, 5, 0
AX25_DBG: c40ccf28, 00000000, 11, 5, 0
AX25_DBG: c4135320, 00000000, 11, 5, 0
AX25_DBG: c4145958, 00000000, 2, 1, 6
AX25_DBG: c40ccf28, 00000000, 11, 5, 0
AX25_DBG: c40e3910, 00000000, 6, 5, 0
AX25_DBG: c40e2cc8, 00000000, 6, 5, 0
AX25_DBG: c4135340, 00000000, 11, 5, 0
AX25_DBG: c40c4ea8, 00000000, 11, 5, 0
AX25_DBG: c4135360, 00000000, 11, 5, 0
AX25_DBG: c40c4ea8, 00000000, 11, 5, 0
AX25_DBG: c40e2cc8, 00000000, 6, 5, 0
AX25_DBG: c4144350, 00000000, 11, 5, 0
AX25_DBG: c4135978, 00000000, 2, 1, 6
AX25_DBG: c40ccf28, 00000000, 11, 5, 0
BUG: unable to handle kernel paging request at 6b6b6b6a
IP: [<c01e9aa8>] _raw_spin_trylock+0x8/0x50
*pde = 00000000 
Oops: 0000 [#1] 
Modules linked in: netrom rose mkiss crc16 ax25 netconsole configfs nfsd exportfs nfs lockd nfs_acl sunrpc af_packet snd_seq_dummy ipv6 snd_seq_oss snd_seq_midi_event snd_seq snd_pcm_oss snd_mixer_oss binfmt_misc loop usb_storage scsi_mod floppy usbhid snd_ens1371 snd_rawmidi snd_seq_device snd_ac97_codec snd_pcm uhci_hcd snd_timer snd soundcore snd_page_alloc intel_agp usbcore ac97_bus ide_cd_mod agpgart ne2k_pci 8390 ext3 jbd ide_disk piix ide_core [last unloaded: nf_conntrack]

Pid: 0, comm: swapper Not tainted (2.6.27-rc7 #3)
EIP: 0060:[<c01e9aa8>] EFLAGS: 00010046 CPU: 0
EIP is at _raw_spin_trylock+0x8/0x50
EAX: 6b6b6b6a EBX: 00000000 ECX: 6b6b6b6a EDX: 00000000
ESI: 6b6b6b6a EDI: 00000292 EBP: c038be60 ESP: c038be5c
 DS: 007b ES: 007b FS: 0000 GS: 0000 SS: 0068
Process swapper (pid: 0, ti=c038a000 task=c03633a0 task.ti=c038a000)
Stack: 6b6b6b7a c038be84 c02c044b 00000000 00000002 00000000 c01263a5 6b6b6b6b 
       6b6b6b6a c40e3ad0 c038be9c c01263a5 c038bea4 c40e3ad0 00000000 c40e3ad0 
       c038beb0 c012640a 00000286 c40e3910 c40e3910 c038beb8 c8ca0efd c038bed4 
Call Trace:
 [<c02c044b>] ? _spin_lock_irqsave+0x4b/0x80
 [<c01263a5>] ? lock_timer_base+0x25/0x50
 [<c01263a5>] ? lock_timer_base+0x25/0x50
 [<c012640a>] ? del_timer+0x3a/0x80
 [<c8ca0efd>] ? ax25_stop_heartbeat+0xd/0x10 [ax25]
 [<c8ca1dad>] ? ax25_destroy_socket+0x1d/0x1e0 [ax25]
 [<c8ca0816>] ? ax25_std_heartbeat_expiry+0xd6/0xe0 [ax25]
 [<c8ca10fb>] ? ax25_heartbeat_expiry+0x1b/0x40 [ax25]
 [<c0125e29>] ? run_timer_softirq+0x149/0x1b0
 [<c8ca10e0>] ? ax25_heartbeat_expiry+0x0/0x40 [ax25]
 [<c8ca10e0>] ? ax25_heartbeat_expiry+0x0/0x40 [ax25]
 [<c0121ce5>] ? __do_softirq+0x55/0xc0
 [<c0121d96>] ? do_softirq+0x46/0x50
 [<c0122107>] ? irq_exit+0x57/0x70
 [<c010639f>] ? do_IRQ+0x4f/0xa0
 [<c01e5d14>] ? trace_hardirqs_off_thunk+0xc/0x18
 [<c01045e4>] ? common_interrupt+0x28/0x30
 [<c01091b8>] ? default_idle+0x38/0x50
 [<c010269d>] ? cpu_idle+0x3d/0x80
 [<c02b8858>] ? rest_init+0x48/0x50
 =======================
Code: d2 33 c0 e8 ab 46 f3 ff 85 db 8b 4e 08 74 8c 8b 93 dc 00 00 00 8d 83 04 02 00 00 eb 88 8d b6 00 00 00 00 55 89 c1 89 e5 53 31 db <8b> 00 c7 01 00 00 00 00 84 c0 0f 9f c3 85 db 75 17 89 c8 ba b8 
EIP: [<c01e9aa8>] _raw_spin_trylock+0x8/0x50 SS:ESP 0068:c038be5c
Kernel panic - not syncing: Fatal exception in interrupt
AX25_DBG: c58ad038, 00000000, 2, 2, 17
AX25_DBG: c58ad350, 00000000, 2, 2, 17
AX25_DBG: c62d6cc8, 00000000, 1, 0, 0
AX25_DBG: c5f1e998, 00000000, 1, 1, 0
AX25_DBG: c62d6cc8, 00000000, 1, 0, 0
AX25_DBG: c5f1e998, 00000000, 1, 1, 0
AX25_DBG: c58ad350, 00000000, 2, 2, 17
AX25_DBG: c58ad350, 00000000, 2, 2, 17
AX25_DBG: c62d6668, 00000000, 1, 0, 0
AX25_DBG: c5f1e998, 00000000, 1, 1, 0
AX25_DBG: c62d6668, 00000000, 1, 0, 0
AX25_DBG: c5f1e998, 00000000, 1, 1, 0
AX25_DBG: c62d6668, 00000000, 1, 0, 0
AX25_DBG: c5f1e998, 00000000, 1, 1, 0
AX25_DBG: c62d6668, 00000000, 1, 0, 0
AX25_DBG: c5f1e998, 00000000, 1, 1, 0
AX25_DBG: c5dfa078, 00000000, 2, 1, 6
AX25_DBG: c584a038, 00000000, 10, 1, 6
AX25_DBG: c5f1e998, 00000000, 1, 1, 0
AX25_DBG: c58ad038, 00000000, 2, 2, 17
AX25_DBG: c58ad038, 00000000, 2, 2, 17
AX25_DBG: c58ad038, 00000000, 2, 2, 17
AX25_DBG: c62d6668, 00000000, 1, 0, 0
AX25_DBG: c5f1e998, 00000000, 1, 1, 0
AX25_DBG: c62d6668, 00000000, 1, 0, 0
AX25_DBG: c5f1e998, 00000000, 1, 1, 0
AX25_DBG: c5dfa078, 00000000, 2, 1, 6
AX25_DBG: c584a038, 00000000, 10, 1, 6
AX25_DBG: c5f1e998, 00000000, 1, 1, 0
AX25_DBG: c58ad038, 00000000, 2, 2, 17
AX25_DBG: c58ad038, 00000000, 2, 2, 17
AX25_DBG: c58ad038, 00000000, 2, 2, 17
AX25_DBG: c62b8320, 00000000, 16, 3, 0
AX25_DBG: c7ade058, 00000000, 10, 2, 17
AX25_DBG: c58ad668, 00000000, 2, 2, 17
AX25_DBG: c62eecc8, 00000000, 1, 0, 0
AX25_DBG: c62d6668, 00000000, 1, 1, 0
AX25_DBG: c62eecc8, 00000000, 1, 0, 0
AX25_DBG: c62d6668, 00000000, 1, 1, 0
AX25_DBG: c5f1e998, 00000000, 1, 1, 0
AX25_DBG: c62d6cc8, 00000000, 1, 1, 0
AX25_DBG: c62d6668, 00000000, 1, 2, 0
AX25_DBG: c62d6668, 00000000, 1, 2, 0
AX25_DBG: c62eecc8, 00000000, 1, 0, 0
AX25_DBG: c62d6668, 00000000, 1, 1, 0
AX25_DBG: c62eecc8, 00000000, 1, 0, 0
AX25_DBG: c62d6668, 00000000, 1, 1, 0
AX25_DBG: c58ad668, 00000000, 2, 2, 17
AX25_DBG: c5f35300, 00000000, 16, 3, 0
AX25_DBG: c58ad668, 00000000, 2, 2, 17
AX25_DBG: c62d6668, 00000000, 1, 2, 0
AX25_DBG: c62d6cc8, 00000000, 1, 1, 0
AX25_DBG: c5f1e998, 00000000, 1, 1, 0
AX25_DBG: c5f1e998, 00000000, 1, 2, 0
AX25_DBG: c5f1e998, 00000000, 1, 2, 0
AX25_DBG: c62b8320, 00000000, 16, 3, 0
AX25_DBG: c7ade058, 00000000, 10, 2, 17
AX25_DBG: c58ad668, 00000000, 2, 2, 17
AX25_DBG: c62d6cc8, 00000000, 1, 0, 0
AX25_DBG: c5f1e998, 00000000, 1, 1, 0
AX25_DBG: c62d6cc8, 00000000, 1, 0, 0
AX25_DBG: c5f1e998, 00000000, 1, 1, 0
AX25_DBG: c62d6cc8, 00000000, 1, 0, 0
AX25_DBG: c5f1e998, 00000000, 1, 1, 0
AX25_DBG: c62d6cc8, 00000000, 1, 0, 0
AX25_DBG: c5f1e998, 00000000, 1, 1, 0
AX25_DBG: c62d6cc8, 00000000, 1, 0, 0
AX25_DBG: c5f1e998, 00000000, 1, 1, 0
AX25_DBG: c62d6cc8, 00000000, 1, 0, 0
AX25_DBG: c5f1e998, 00000000, 1, 1, 0
AX25_DBG: c62d6cc8, 00000000, 1, 0, 0
AX25_DBG: c5f1e998, 00000000, 1, 1, 0
AX25_DBG: c62d6cc8, 00000000, 1, 0, 0
AX25_DBG: c5f1e998, 00000000, 1, 1, 0
AX25_DBG: c62d6cc8, 00000000, 1, 0, 0
AX25_DBG: c5f1e998, 00000000, 1, 1, 0
AX25_DBG: c62d6cc8, 00000000, 1, 0, 0
AX25_DBG: c5f1e998, 00000000, 1, 1, 0
AX25_DBG: c62d6cc8, 00000000, 1, 0, 0
AX25_DBG: c5f1e998, 00000000, 1, 1, 0
AX25_DBG: c62d6cc8, 00000000, 1, 0, 0
AX25_DBG: c5f1e998, 00000000, 1, 1, 0
AX25_DBG: c5f172e0, 00000000, 16, 3, 0
AX25_DBG: c58ad038, 00000000, 2, 2, 17
AX25_DBG: c58ad038, 00000000, 2, 2, 17
AX25_DBG: c58ad038, 00000000, 2, 2, 17
AX25_DBG: c58ad038, 00000000, 2, 2, 17
AX25_DBG: c58ad038, 00000000, 2, 2, 17
AX25_DBG: c58ad038, 00000000, 2, 2, 17
AX25_DBG: c58ad038, 00000000, 2, 2, 17
AX25_DBG: c58ad038, 00000000, 2, 2, 17
AX25_DBG: c5f172e0, 00000000, 16, 3, 0
AX25_DBG: c58ad038, 00000000, 2, 2, 17
AX25_DBG: c58ad038, 00000000, 2, 2, 17
AX25_DBG: c58ad038, 00000000, 2, 2, 17
AX25_DBG: c58ad038, 00000000, 2, 2, 17
AX25_DBG: c58ad038, 00000000, 2, 2, 17
AX25_DBG: c58ad038, 00000000, 2, 2, 17
AX25_DBG: c58ad038, 00000000, 2, 2, 17
AX25_DBG: c58ad038, 00000000, 2, 2, 17
AX25_DBG: c5f172e0, 00000000, 16, 3, 0
AX25_DBG: c58ad038, 00000000, 2, 2, 17
AX25_DBG: c58ad038, 00000000, 2, 2, 17
AX25_DBG: c58ad038, 00000000, 2, 2, 17
AX25_DBG: c58ad038, 00000000, 2, 2, 17
AX25_DBG: c58ad038, 00000000, 2, 2, 17
AX25_DBG: c58ad038, 00000000, 2, 2, 17
AX25_DBG: c58ad038, 00000000, 2, 2, 17
AX25_DBG: c58ad038, 00000000, 2, 2, 17
AX25_DBG: c5f172e0, 00000000, 16, 3, 0
AX25_DBG: c58ad668, 00000000, 2, 2, 17
AX25_DBG: c58ad668, 00000000, 2, 2, 17
AX25_DBG: c58ad668, 00000000, 2, 2, 17
AX25_DBG: c58ad668, 00000000, 2, 2, 17
AX25_DBG: c58ad668, 00000000, 2, 2, 17
AX25_DBG: c58ad668, 00000000, 2, 2, 17
AX25_DBG: c58ad668, 00000000, 2, 2, 17
AX25_DBG: c58ad668, 00000000, 2, 2, 17
AX25_DBG: c5f172e0, 00000000, 16, 3, 0
AX25_DBG: c58ad668, 00000000, 2, 2, 17
AX25_DBG: c58ad668, 00000000, 2, 2, 17
AX25_DBG: c58ad668, 00000000, 2, 2, 17
AX25_DBG: c58ad668, 00000000, 2, 2, 17
AX25_DBG: c58ad668, 00000000, 2, 2, 17
AX25_DBG: c58ad668, 00000000, 2, 2, 17
AX25_DBG: c58ad668, 00000000, 2, 2, 17
AX25_DBG: c58ad668, 00000000, 2, 2, 17
AX25_DBG: c5f172e0, 00000000, 16, 3, 0
AX25_DBG: c58ad668, 00000000, 2, 2, 17
AX25_DBG: c58ad668, 00000000, 2, 2, 17
AX25_DBG: c58ad668, 00000000, 2, 2, 17
AX25_DBG: c58ad668, 00000000, 2, 2, 17
AX25_DBG: c58ad668, 00000000, 2, 2, 17
AX25_DBG: c58ad668, 00000000, 2, 2, 17
AX25_DBG: c58ad668, 00000000, 2, 2, 17
AX25_DBG: c58ad668, 00000000, 2, 2, 17
BUG: spinlock trylock failure on UP on CPU#0, swapper/0
 lock: c653f194, .magic: dead4ead, .owner: swapper/0, .owner_cpu: 0
Pid: 0, comm: swapper Not tainted 2.6.27-rc7 #3
 [<c01e9a4a>] spin_bug+0x8a/0xe0
 [<c01e9ac5>] _raw_spin_trylock+0x25/0x50
 [<c02bfbde>] _spin_trylock+0xe/0x50
 [<c0265562>] netpoll_send_skb+0x132/0x190
 [<c0265a5d>] netpoll_send_udp+0x1ed/0x200
 [<c8afd17c>] write_msg+0x9c/0xe0 [netconsole]
 [<c8afd0e0>] ? write_msg+0x0/0xe0 [netconsole]
 [<c011d5e7>] __call_console_drivers+0x47/0x60
 [<c011d679>] _call_console_drivers+0x79/0x90
 [<c011da50>] release_console_sem+0xc0/0x1e0
 [<c011e000>] vprintk+0x290/0x3c0
 [<c014023c>] ? __lock_acquire+0x37c/0x9b0
 [<c013b8eb>] ? trace_hardirqs_off+0xb/0x10
 [<c011e14b>] printk+0x1b/0x20
 [<c024e5ac>] sk_free+0x3c/0x130
 [<c02500cd>] sock_wfree+0x2d/0x40
 [<c02524ba>] skb_release_all+0x3a/0x90
 [<c0251c5b>] __kfree_skb+0xb/0x90
 [<c0251cf9>] kfree_skb+0x19/0x30
 [<c89e1f74>] ei_start_xmit+0x164/0x330 [8390]
 [<c0257de0>] dev_hard_start_xmit+0x210/0x280
 [<c02bff38>] ? _spin_lock+0x58/0x60
 [<c0267fed>] __qdisc_run+0x16d/0x1e0
 [<c025a708>] dev_queue_xmit+0x1c8/0x4d0
 [<c025a57b>] ? dev_queue_xmit+0x3b/0x4d0
 [<c0121e0b>] ? local_bh_enable_ip+0x6b/0xb0
 [<c0260559>] neigh_resolve_output+0xe9/0x290
 [<c0121e0b>] ? local_bh_enable_ip+0x6b/0xb0
 [<c025e8ac>] neigh_update+0x23c/0x420
 [<c0121e0b>] ? local_bh_enable_ip+0x6b/0xb0
 [<c02676c0>] ? eth_header_cache_update+0x0/0x20
 [<c0294f6f>] arp_process+0x2ff/0x670
 [<c0294c70>] ? arp_process+0x0/0x670
 [<c026cd56>] ? nf_hook_slow+0xe6/0x100
 [<c0294c70>] ? arp_process+0x0/0x670
 [<c02953a9>] arp_rcv+0xc9/0x120
 [<c0294c70>] ? arp_process+0x0/0x670
 [<c02952e0>] ? arp_rcv+0x0/0x120
 [<c0257742>] netif_receive_skb+0x232/0x2e0
 [<c02575ea>] ? netif_receive_skb+0xda/0x2e0
 [<c025a163>] process_backlog+0x63/0xc0
 [<c02599ee>] net_rx_action+0x13e/0x1d0
 [<c0259910>] ? net_rx_action+0x60/0x1d0
 [<c0121ce5>] __do_softirq+0x55/0xc0
 [<c0121d96>] do_softirq+0x46/0x50
 [<c0122107>] irq_exit+0x57/0x70
 [<c010639f>] do_IRQ+0x4f/0xa0
 [<c01e5d14>] ? trace_hardirqs_off_thunk+0xc/0x18
 [<c01045e4>] common_interrupt+0x28/0x30
 [<c013007b>] ? sys_timer_delete+0x10b/0x110
 [<c01091b8>] ? default_idle+0x38/0x50
 [<c010269d>] cpu_idle+0x3d/0x80
 [<c02b8858>] rest_init+0x48/0x50
 =======================
AX25_DBG: c5dfa078, 00000000, 2, 1, 6
AX25_DBG: c58ad668, 00000000, 2, 2, 17
AX25_DBG: c58ad038, 00000000, 2, 2, 17
AX25_DBG: c58ad668, 00000000, 2, 2, 17
AX25_DBG: c62d6cc8, 00000000, 1, 0, 0
AX25_DBG: c5f1e998, 00000000, 1, 1, 0
AX25_DBG: c62d6cc8, 00000000, 1, 0, 0
AX25_DBG: c5f1e998, 00000000, 1, 1, 0
AX25_DBG: c58ad668, 00000000, 2, 2, 17
AX25_DBG: c58ad668, 00000000, 2, 2, 17


--=-BBas9fs3pwWlCj97muGW--

