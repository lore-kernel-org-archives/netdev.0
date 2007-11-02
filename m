From: David Brownell <david-b@pacbell.net>
Subject: Re: build #337 failed for 2.6.24-rc1-gb1d08ac In function `usbnet_set_settings':
Date: Fri, 2 Nov 2007 12:30:22 -0700
Message-ID: <200711021230.22588.david-b@pacbell.net>
References: <200711012024.57412.toralf.foerster@gmx.de> <200711021145.15542.david-b@pacbell.net> <20071102185751.GV30287@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Randy Dunlap <randy.dunlap@oracle.com>,
	Toralf =?iso-8859-1?q?F=F6rster?= <toralf.foerster@gmx.de>,
	linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: Adrian Bunk <bunk@kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp115.sbc.mail.sp1.yahoo.com ([69.147.64.88]:47948 "HELO
	smtp115.sbc.mail.sp1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1757336AbXKBTaZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Nov 2007 15:30:25 -0400
In-Reply-To: <20071102185751.GV30287@stusta.de>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Friday 02 November 2007, Adrian Bunk wrote:
> This approach has two disadvantages:
> - it's complicated

No more so than the problem itself.


> - the MII stuff is an implementation detail, and we shouldn't bother
> =A0 the user with it (especially since we can do better)

That's a Kconfig policy that's not always followed.  In this
case, I was getting fed up with "select".  It so rarely does
what it needs to do, and I've started to think it'd be better
to just always avoid that fragility than battle it.

=20
> If you want to keep the #ifdef's, what's the problem with the second=20
> patch I proposed to fix this bug?

=46or one thing, I didn't see it until after I posted this one...
other than that, the basic approach could well be fine; I didn't
go through it in detail.

But on the other hand, it seems that only the ASIX code will work
right; the DM9601 and MCS7830 Kconfig is different/wrong.

- Dave


