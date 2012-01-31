From: "Henrik Rydberg" <rydberg@euromail.se>
Subject: Re: brcm80211 breakage..
Date: Tue, 31 Jan 2012 23:23:11 +0100
Message-ID: <20120131222311.GA3639@polaris.bitmath.org>
References: <CA+55aFx2UnVZP1Z44dMHeifB2nD1zJ87kz25zZjUdwv0ozwKPA@mail.gmail.com>
 <20120131120846.GA8799@polaris.bitmath.org>
 <CA+55aFy5-x6Zevga=rX_q+6vsmXFHyMJ+m8YqrqjC6yELqS6mw@mail.gmail.com>
 <4F283C16.5090508@broadcom.com>
 <20120131192520.GA2974@tuxdriver.com>
 <20120131195822.GA2175@polaris.bitmath.org>
 <4F284D34.9000602@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "John W. Linville" <linville@tuxdriver.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	"Franky (Zhenhui) Lin" <frankyl@broadcom.com>,
	"John W. Linville" <linville@redhat.com>,
	Network Development <netdev@vger.kernel.org>,
	=?utf-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>,
	Hauke Mehrtens <hauke@hauke-m.de>
To: Arend van Spriel <arend@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtprelay-b11.telenor.se ([62.127.194.20]:47743 "EHLO
	smtprelay-b11.telenor.se" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752619Ab2AaWyw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Jan 2012 17:54:52 -0500
Received: from ipb4.telenor.se (ipb4.telenor.se [195.54.127.167])
	by smtprelay-b11.telenor.se (Postfix) with ESMTP id 80361C5A0
	for <netdev@vger.kernel.org>; Tue, 31 Jan 2012 23:22:24 +0100 (CET)
Content-Disposition: inline
In-Reply-To: <4F284D34.9000602@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> > The brcmsmac driver is now using the bcma SPROM logic, which does not
> > recognize all chipsets that were functional prior to the switch. In
> > particular, the current code bails out on odd CRC errors in recent
> > Macbooks. This patch ignores those errors, with the argument that an
> > unrecognized SPROM should be treated similarly to a non-existing one.
> >
> 
> Not entirely correct. BCMA sprom logic is currently not used by
> brcmsmac, but it sure (as hell) makes sense to do so. Currently, the
> bcma SPROM logic is used in SoC chipsets (bcm47xx) and the b43 driver.

Let's change that to "bcma SPROM CRC check", then. With -rc2 just out, I
take it the patch will appear in -rc3?

Thanks,
Henrik
