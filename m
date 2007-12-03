From: "David Schwartz" <davids@webmaster.com>
Subject: RE: namespace support requires network modules to say "GPL"
Date: Sun, 2 Dec 2007 16:02:17 -0800
Message-ID: <MDEHLPKNGKAHNMBLJOLKGEDMIJAC.davids@webmaster.com>
References: <20071201192341.6750fbdb@the-village.bc.nu>
Reply-To: davids@webmaster.com
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 7bit
Cc: "Mark Lord" <lkml@rtr.ca>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	"Greg Kroah-Hartman" <gregkh@suse.de>, "Greg KH" <greg@kroah.com>,
	"Tejun Heo" <htejun@gmail.com>,
	"Linux Containers" <containers@lists.osdl.org>,
	<netdev@vger.kernel.org>, <cornelia.huck@de.ibm.com>,
	<stern@rowland.harvard.edu>, <kay.sievers@vrfy.org>,
	<linux-kernel@vger.kernel.org>,
	"Andrew Morton" <akpm@linux-foundation.org>,
	"Herbert Xu" <herbert@gondor.apana.org.au>,
	"David Miller" <davem@davemloft.net>,
	"Linus Torvalds" <torvalds@linux-foundation.org>
To: "Stephen Hemminger" <shemminger@linux-foundation.org>,
	"Alan Cox" <alan@lxorguk.ukuu.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.webmaster.com ([216.152.64.169]:4856 "EHLO
	mail1.webmaster.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751884AbXLCADS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 2 Dec 2007 19:03:18 -0500
In-Reply-To: <20071201192341.6750fbdb@the-village.bc.nu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> > Then init_net needs to be not GPL limited. Sorry, we need to allow
> > non GPL network drivers.  There is a fine line between keeping the

> Why - they aren't exactly likely to be permissible by law

Really? What law and/or what clause in the GPL says that derivative works
have to be licensed under the GPL? Or does the kernel have some new
technique to determine whether or not code has been distributed?

As I read the GPL, it only requires you to release something under the GPL
if you distribute it. The kernel has no idea whether or not code has been
distributed. So if it's enforcing the GPL, it cannot prohibit anything
non-distributed code can lawfully do. (Ergo, it's *NOT* *ENFORCING* the
GPL.)

> > binary seething masses from accessing random kernel functions,
> and allowing
> > reasonable (but still non GPL) things like ndiswrapper to use network
> > device interface.
>
> Its up to the ndiswrapper authors how the licence their code, but they
> should respect how we licence ours.

You license yours under the GPL, so they should respect the GPL.

It sounds like we're back to where we were years ago. Didn't we already
agree that EXPORT_SYMBOL_GPL was *NOT* a GPL-enforcement mechanism and had
nothing to do with respecting the GPL? After all, if it s a GPL-enforcement
mechanism, why is it not a "further restriction" which is prohibited by the
GPL? (The GPL contains no restrictions on what code can use what symbols if
that code is not distributed, but EXPORT_SYMBOL_GPL does.)

Are you now claiming that EXPORT_SYMBOL_GPL is intended to enforce the GPL?

DS


