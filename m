From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: [PATCH] sky2: don't clear phy power bits
Date: Tue, 21 Aug 2007 11:26:23 -0700 (PDT)
Message-ID: <alpine.LFD.0.999.0708211123510.30176@woody.linux-foundation.org>
References: <20070821064251.972690753@blue.kroah.org> <20070821065421.GG5275@kroah.com>
 <20070821111022.046eec14@freepuppy.rosehill.hemminger.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=us-ascii
Cc: Greg KH <gregkh@suse.de>, stable@vger.kernel.org,
	stable@kernel.org, Justin Forbes <jmforbes@linuxtx.org>,
	Zwane Mwaikambo <zwane@arm.linux.org.uk>,
	"Theodore Ts'o" <tytso@mit.edu>,
	Randy Dunlap <rdunlap@xenotime.net>,
	Dave Jones <davej@redhat.com>,
	Chuck Wolber <chuckw@quantumlinux.com>,
	Chris Wedgwood <reviews@ml.cw.f00f.org>,
	Michael Krufky <mkrufky@linuxtv.org>,
	Chuck Ebbert <cebbert@redhat.com>,
	Domenico Andreoli <cavokz@gmail.com>,
	akpm@linux-foundation.org, alan@lxorguk.ukuu.org.uk,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:54867 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1761951AbXHUS1m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Aug 2007 14:27:42 -0400
In-Reply-To: <20070821111022.046eec14@freepuppy.rosehill.hemminger.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On Tue, 21 Aug 2007, Stephen Hemminger wrote:
>
> There are special PHY settings available on Yukon EC-U chip that
> should not get cleared. This should solve mysterious errors on some
> motherboards (like Gigabyte DS-3).

Ok, applied.

However:

 - now all accesses to GPHY_CTRL are 8-bit (it used to mix them). Good.

 - but sky2.h still says "32 bit" about the register

Should the comments in sky2.h perhaps be fixed?

		Linus
