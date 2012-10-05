From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH 19/20] drivers/net/ethernet/marvell/skge.c: fix error
 return code
Date: Thu, 04 Oct 2012 17:09:55 -0700
Message-ID: <1349395795.2008.26.camel@joe-AO722>
References: <CA+MoWDp=_F9opJbVkv9sDsmoykm7MTUZwRVumKCB0ZqDwD6NoQ@mail.gmail.com>
	 <20121004.142335.1467206545795435493.davem@davemloft.net>
	 <CA+MoWDqBF5bdQYBaUmpB99Q=YcHYcUxi8Ffo3x4s0B+pmomb+Q@mail.gmail.com>
	 <20121004.145419.1859367129463136197.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: peter.senna@gmail.com, shemminger@vyatta.com, mlindner@marvell.com,
	kernel-janitors@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from perches-mx.perches.com ([206.117.179.246]:51995 "EHLO
	labridge.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752867Ab2JEAJ5 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Oct 2012 20:09:57 -0400
In-Reply-To: <20121004.145419.1859367129463136197.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-10-04 at 14:54 -0400, David Miller wrote:
> From: Peter Senna Tschudin <peter.senna@gmail.com>
> > On Thu, Oct 4, 2012 at 8:23 PM, David Miller <davem@davemloft.net> wrote:
> >> We want to know the implications of the bug being fixed.
> >> Does it potentially cause an OOPS?  Bad reference counting and thus
> >> potential leaks or early frees?
> >>
> >> You have to analyze the implications and ramifications of the bug
> >> being fixed.  We need that information.

You are asking for deeper level analysis that may not
be reasonably possible from the robotic patch fixed
by a robotic piece of a bit of code correction via a
static analysis.

> >> It's just "bad error code, this is the script that fixed it, kthx,
> >> bye" which is pretty much useless for anaylsis.

Which may be all but impossible but for the handful of
folks that know all the gory/intimate details of the
original bit of code.

> What does it potentially cause the caller to do?  Will it potentially
> treat an error as a success and as a result register an object
> illegally?
> 
> Real analysis please.  The text you provided above is basically still
> robotic and could be used to describe any error code return fix.

Right, it's useful to attempt but may be infeasible in
practice.
