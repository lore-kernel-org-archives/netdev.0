From: One Thousand Gnomes <gnomes@lxorguk.ukuu.org.uk>
Subject: Re: [PATCH 1/3] ser_gigaset: fix up NULL checks
Date: Wed, 9 Dec 2015 12:12:35 +0000
Message-ID: <20151209121235.227acac9@lxorguk.ukuu.org.uk>
References: <cover.1449570042.git.tilman@imap.cc>
	<ed83fae92c8c56e659f59c9a3709c86bd3a7d0c4.1449570042.git.tilman@imap.cc>
	<1449603913.2384.16.camel@tiscali.nl>
	<20151208221657.71fd0d71@lxorguk.ukuu.org.uk>
	<56680665.4000301@imap.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Paul Bolle <pebolle@tiscali.nl>, netdev@vger.kernel.org,
	Peter Hurley <peter@hurleysoftware.com>,
	Sasha Levin <sasha.levin@oracle.com>,
	syzkaller@googlegroups.com, David Miller <davem@davemloft.net>,
	Karsten Keil <isdn@linux-pingi.de>,
	isdn4linux@listserv.isdn4linux.de,
	gigaset307x-common@lists.sourceforge.net,
	linux-kernel@vger.kernel.org
To: Tilman Schmidt <tilman@imap.cc>
Return-path: <netdev-owner@vger.kernel.org>
Received: from lxorguk.ukuu.org.uk ([81.2.110.251]:42039 "EHLO
	lxorguk.ukuu.org.uk" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754147AbbLIMNJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Dec 2015 07:13:09 -0500
In-Reply-To: <56680665.4000301@imap.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 9 Dec 2015 11:45:57 +0100
Tilman Schmidt <tilman@imap.cc> wrote:

> Am 08.12.2015 um 23:16 schrieb One Thousand Gnomes:
> > The right fix as far as I can see is to remove the tests although
> > WARN_ON() combined with your tty->ops change might be safer.
> 
> Feel free to submit a patch.

Will do later today. Want a patch on top of Paul's change or a single
patch including both and crediting him ?

> > tty locking reviews, but drivers/isdn and net/irda weren't traditionally
> > part of the general tty maintenance but handled separately/
> 
> Or just ignored.

Unfortunately at the time that seemed to happen a lot.

> >> test puzzle me. It's not obvious why they're needed. Ie, can the null
> >> dereferences they try to catch really happen? But I can try to figure
> >> out that in the future, if I ever feel the urge to do so. Anyhow:
> >>
> >> Acked-by: Paul Bolle <pebolle@tiscali.nl>
> > 
> > Nacked-by: Alan Cox <alan@linux.intel.com>
> 
> So you feel it's better to maintain the current inconsistent state
> created by commit f34d7a5b? Please elaborate.

No I'd rather we didn't make it look magically better then forget about
the mess in question.

Alan
