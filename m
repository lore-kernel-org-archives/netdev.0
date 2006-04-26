From: Nuri Jawad <lkml@jawad.org>
Subject: Re: Fw: Bug: PPP dropouts in >=2.6.16
Date: Wed, 26 Apr 2006 02:36:18 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0604260126020.12542@pc>
References: <20060421010809.6c3cfc34.akpm@osdl.org>
 <4807377b0604211015j16b40cccpe215668f8fdcfc24@mail.gmail.com>
 <200604220202.59434.ak@suse.de> <20060424074148.GB23340@zion.homelinux.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Andi Kleen <ak@suse.de>,
	Jesse Brandeburg <jesse.brandeburg@gmail.com>,
	Andrew Morton <akpm@osdl.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from leitseite.net ([213.239.214.51]:11462 "EHLO mail.leitseite.net")
	by vger.kernel.org with ESMTP id S932318AbWDZAgw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 Apr 2006 20:36:52 -0400
To: Sven Schuster <schuster.sven@gmx.de>
In-Reply-To: <20060424074148.GB23340@zion.homelinux.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> no problems here with pppoe, kernel is 2.6.17-rc1-mm1, ppp 2.4.4-b1.

Did you create a high load on the system in the manner I described?
The bug once only appeared after about 6 hours here when line + CPU had 
been mostly idle. But that was the longest time between failures. Can you 
test with one of the 2.6.16 kernels I tried (latest was .9)? Can't say 
for sure if CPU load is a factor, load on the connection seems to be.

After using 2.6.15.7 for another 5 days now with some more stress 
testing, I can assure that 2.6.15 definitely does not produce any 
dropouts on this machine.

For now I'll try to reproduce the effects on my second box (AMD64/nf4).
I'd be happy if someone could give me some hints on which patches I could 
try to revert as the changes to ppp between the two versions look fairly 
harmless. For the first time in 8.5 years, I cannot use a 'stable' kernel 
release and there is really nothing special about this system.

Regards,
Nuri
