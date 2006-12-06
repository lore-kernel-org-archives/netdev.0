From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: Kernel header changes break glibc build
Date: Wed, 06 Dec 2006 14:07:19 +0000
Message-ID: <1165414039.5253.233.camel@pmac.infradead.org>
References: <Pine.LNX.4.64.0610061718370.18057@digraph.polyomino.org.uk>
	 <1165148731.12649.51.camel@pmac.infradead.org>
	 <20061204091341.GM8693@postel.suug.ch>
	 <1165410114.5253.218.camel@pmac.infradead.org>
	 <20061206134308.GL9556@sunsite.mff.cuni.cz>
	 <20061206135931.GB8693@postel.suug.ch>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Jakub Jelinek <jakub@redhat.com>,
	Ulrich Drepper <drepper@redhat.com>,
	"Joseph S. Myers" <joseph@codesourcery.com>,
	netdev@vger.kernel.org, libc-alpha@sourceware.org, akpm@osdl.org,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:41520 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760627AbWLFOHY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Dec 2006 09:07:24 -0500
To: Thomas Graf <tgraf@suug.ch>
In-Reply-To: <20061206135931.GB8693@postel.suug.ch>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2006-12-06 at 14:59 +0100, Thomas Graf wrote:
> Are you suggesting that the kernel has to keep macros around which
> are of no use to the kernel itself just because glibc uses them?

No, although in fact that _is_ the only reason we use these horrid __uXX
types rather than proper C datatypes, isn't it?

I'm suggesting that if you want to change things around as you did, you
should make sure the users of those headers adapt to cope. You did fix
the in-kernel users; you neglected to fix glibc -- and as far as I can
tell you didn't even bother to _warn_ glibc folks.

We need to do better than that. The dark ages where we used to toss a
pile of crap over the wall and declare it was someone else's problem are
now behind us, thankfully.

-- 
dwmw2

