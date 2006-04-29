From: Nuri Jawad <lkml@jawad.org>
Subject: Re: Fw: Bug: PPP dropouts in >=2.6.16
Date: Sat, 29 Apr 2006 02:05:29 +0200 (CEST)
Message-ID: <Pine.LNX.4.64.0604272330360.14398@pc>
References: <20060421010809.6c3cfc34.akpm@osdl.org>
 <4807377b0604211015j16b40cccpe215668f8fdcfc24@mail.gmail.com>
 <200604220202.59434.ak@suse.de> <20060424074148.GB23340@zion.homelinux.com>
 <Pine.LNX.4.64.0604260126020.12542@pc> <20060426060442.GA8875@zion.homelinux.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Andi Kleen <ak@suse.de>,
	Jesse Brandeburg <jesse.brandeburg@gmail.com>,
	Andrew Morton <akpm@osdl.org>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from leitseite.net ([213.239.214.51]:7384 "EHLO mail.leitseite.net")
	by vger.kernel.org with ESMTP id S965037AbWD2AGA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Apr 2006 20:06:00 -0400
To: Sven Schuster <schuster.sven@gmx.de>
In-Reply-To: <20060426060442.GA8875@zion.homelinux.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 26 Apr 2006, Sven Schuster wrote:

> but don't hold your breath waiting for me, kernel compile
> takes more than two hours on my box :-)

Ouch. Takes 5/7 minutes here on the AMD64 resp. P4. Computer museum? :P
Anyhow, I tested PPP for 2.5 hours on the AMD64 the day before 
yesterday with a bidirectional transfer that maxed out the upstream.
Last night, I additionally put some load on the CPU. Another 3 hours, no 
problems whatsoever. Looks like the bug does not manifest on that system.

The next step will be to clone .config's settings as far as possible with 
the different hardware and try again.

Regards,
Nuri
