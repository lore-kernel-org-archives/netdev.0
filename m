From: Ingo Molnar <mingo@elte.hu>
Subject: Re: [PULL -tip] fixed few make headers_check warnings
Date: Thu, 15 Jan 2009 12:11:34 +0100
Message-ID: <20090115111134.GB22850@elte.hu>
References: <1231836016.3212.41.camel@jaswinder.satnam> <Pine.LNX.4.64.0901140954250.27308@anakin> <3f9a31f40901140129i1389f47frf32808f3a695a118@mail.gmail.com> <20090114153825.GB32082@uranus.ravnborg.org> <3f9a31f40901140759s1542e6cclae1808b796c2b1a9@mail.gmail.com> <Pine.LNX.4.64.0901141732450.26663@anakin> <20090114201513.GC1556@uranus.ravnborg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Geert Uytterhoeven <geert@linux-m68k.org>,
	Jaswinder Singh Rajput <jaswinderlinux@gmail.com>,
	Jaswinder Singh Rajput <jaswinder@infradead.org>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>,
	x86 maintainers <x86@kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Sam Ravnborg <sam@ravnborg.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx3.mail.elte.hu ([157.181.1.138]:48372 "EHLO mx3.mail.elte.hu"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753797AbZAOLMX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 Jan 2009 06:12:23 -0500
Content-Disposition: inline
In-Reply-To: <20090114201513.GC1556@uranus.ravnborg.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


* Sam Ravnborg <sam@ravnborg.org> wrote:

> So when I see "capability.h: extern's make no sense in userspace" the 
> perfect approach would be that the whole file was checked.
> 
> This is a much bigger task that just removing the warning.

The problem is, you just littered the kernel with a ton of warnings and 
declared that fixing them is a 'much bigger task'.

It's not good to start projects like this, because they simply never 
finish. It's _much_ better to first reach a zero baseline via minimal 
fixes, then enforce 'look at the whole thing' for all _NEW_ files and 
changes.

That's how we are using checkpatch in the -tip topics, and it's working 
very nicely.

Could we please start it like that?

	Ingo
