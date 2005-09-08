From: Andrew Morton <akpm@osdl.org>
Subject: Re: [PATCH] 3c59x: read current link status from phy
Date: Thu, 8 Sep 2005 15:41:14 -0700
Message-ID: <20050908154114.69307f92.akpm@osdl.org>
References: <200509080125.j881PcL9015847@hera.kernel.org>
	<431F9899.4060602@pobox.com>
	<Pine.LNX.4.63.0509081351160.21354@dingo.iwr.uni-heidelberg.de>
	<1126184700.4805.32.camel@tsc-6.cph.tpack.net>
	<Pine.LNX.4.63.0509081521140.21354@dingo.iwr.uni-heidelberg.de>
	<1126190554.4805.68.camel@tsc-6.cph.tpack.net>
	<Pine.LNX.4.63.0509081713500.22954@dingo.iwr.uni-heidelberg.de>
	<4320BD96.3060307@tpack.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Bogdan.Costescu@iwr.uni-heidelberg.de, jgarzik@pobox.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S965066AbVIHWmO@vger.kernel.org>
To: Tommy Christensen <tommy.christensen@tpack.net>
In-Reply-To: <4320BD96.3060307@tpack.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Tommy Christensen <tommy.christensen@tpack.net> wrote:
>
> In order to spare some I/O operations, be more intelligent about
>  when to read from the PHY.

Seems sane.

Should we also decrease the polling interval?  Perhaps only when the cable
is unplugged?
