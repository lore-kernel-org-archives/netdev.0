From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: Re: [PATCH] sky2: don't clear phy power bits
Date: Tue, 21 Aug 2007 11:50:11 -0700
Message-ID: <20070821115011.63d9fc7c@freepuppy.rosehill.hemminger.net>
References: <20070821064251.972690753@blue.kroah.org>
	<20070821065421.GG5275@kroah.com>
	<20070821111022.046eec14@freepuppy.rosehill.hemminger.net>
	<alpine.LFD.0.999.0708211123510.30176@woody.linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
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
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:50619 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1759917AbXHUSwC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Aug 2007 14:52:02 -0400
In-Reply-To: <alpine.LFD.0.999.0708211123510.30176@woody.linux-foundation.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 21 Aug 2007 11:26:23 -0700 (PDT)
Linus Torvalds <torvalds@linux-foundation.org> wrote:

> 
> 
> On Tue, 21 Aug 2007, Stephen Hemminger wrote:
> >
> > There are special PHY settings available on Yukon EC-U chip that
> > should not get cleared. This should solve mysterious errors on some
> > motherboards (like Gigabyte DS-3).
> 
> Ok, applied.
> 
> However:
> 
>  - now all accesses to GPHY_CTRL are 8-bit (it used to mix them). Good.
> 
>  - but sky2.h still says "32 bit" about the register
> 
> Should the comments in sky2.h perhaps be fixed?
> 

Register is 32 bit, I'll add documentation about other bits.

-- 
Stephen Hemminger <shemminger@linux-foundation.org>
