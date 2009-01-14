From: Jaswinder Singh Rajput <jaswinderlinux@gmail.com>
Subject: Re: [PULL -tip] fixed few make headers_check warnings
Date: Wed, 14 Jan 2009 22:28:19 +0530
Message-ID: <3f9a31f40901140858w3a024023h94ebb1a6e087d03e@mail.gmail.com>
References: <1231836016.3212.41.camel@jaswinder.satnam>
	 <Pine.LNX.4.64.0901140954250.27308@anakin>
	 <3f9a31f40901140129i1389f47frf32808f3a695a118@mail.gmail.com>
	 <20090114153825.GB32082@uranus.ravnborg.org>
	 <3f9a31f40901140759s1542e6cclae1808b796c2b1a9@mail.gmail.com>
	 <Pine.LNX.4.64.0901141732450.26663@anakin>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Sam Ravnborg <sam@ravnborg.org>,
	Jaswinder Singh Rajput <jaswinder@infradead.org>,
	Ingo Molnar <mingo@elte.hu>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>,
	x86 maintainers <x86@kernel.org>,
	LKML <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Geert Uytterhoeven <geert@linux-m68k.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wa-out-1112.google.com ([209.85.146.177]:14083 "EHLO
	wa-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1762845AbZANQ6U (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Jan 2009 11:58:20 -0500
In-Reply-To: <Pine.LNX.4.64.0901141732450.26663@anakin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jan 14, 2009 at 10:06 PM, Geert Uytterhoeven
<geert@linux-m68k.org> wrote:
> What Sam means is that the warnings about externs not making sense in userspace
> are indicators that there may be other external declarations (without "extern")
> in those files, and that you should fix those at the same time (i.e. either
> don't fix any of them, or fix all of them (in the same file)). If you don't
> fix them at the same time, people tend to forget about them.
>
> So the warnings are just considered canaries in our coal mine. Killing only the
> canaries doesn't help.
>

If this is the case, then drop extern patches and let maintainers of
those files should handle them then they will not forget and never
repeat this mistake again.

--
JSR
