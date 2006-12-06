From: Thomas Graf <tgraf@suug.ch>
Subject: Re: Kernel header changes break glibc build
Date: Wed, 6 Dec 2006 14:59:31 +0100
Message-ID: <20061206135931.GB8693@postel.suug.ch>
References: <Pine.LNX.4.64.0610061718370.18057@digraph.polyomino.org.uk> <1165148731.12649.51.camel@pmac.infradead.org> <20061204091341.GM8693@postel.suug.ch> <1165410114.5253.218.camel@pmac.infradead.org> <20061206134308.GL9556@sunsite.mff.cuni.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ulrich Drepper <drepper@redhat.com>,
	David Woodhouse <dwmw2@infradead.org>,
	"Joseph S. Myers" <joseph@codesourcery.com>,
	netdev@vger.kernel.org, libc-alpha@sourceware.org, akpm@osdl.org,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:48094 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760606AbWLFN7L (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Dec 2006 08:59:11 -0500
To: Jakub Jelinek <jakub@redhat.com>
Content-Disposition: inline
In-Reply-To: <20061206134308.GL9556@sunsite.mff.cuni.cz>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Jakub Jelinek <jakub@redhat.com> 2006-12-06 14:43
> On Wed, Dec 06, 2006 at 01:01:54PM +0000, David Woodhouse wrote:
> > No. They _are_ doing it right -- they're running 'make headers_install'
> > against the 2.6.19 kernel and only _now_ are they finding that we broke
> > it without even the courtesy of a warning, let alone any consultation.
> > 
> > If _we_ had done it right, then they would have been warned when we
> > decided to change this, and we wouldn't have just released 2.6.19 with
> > changes which break the glibc build.
> 
> Yeah, I don't think glibc was doing anything wrong and the 2.6.19
> changes to the make headers_install created headers mean we'd
> either need to add configure checks for the headers (we can't
> simply #include <linux/if_addr.h> because that header didn't
> exist pre 2.6.19 and IF*_{RTA,PAYLOAD} macros were dropped anyway),
> or we need to start defining this ourselves.

Are you suggesting that the kernel has to keep macros around which
are of no use to the kernel itself just because glibc uses them?

What's wrong with copying the headers and ship them? Every glibc
release is based on some kernel version anyway and its no problem
to run glibc compiled with a 2.6.19 header set on a 2.6.18 kernel.
