From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [Bugme-new] [Bug 8724] New: Unaligned acess in udp_recvmsg() on
 EV56
Date: Thu, 12 Jul 2007 11:31:11 -0700
Message-ID: <20070712113111.8ba886e2.akpm@linux-foundation.org>
References: <bug-8724-10286@http.bugzilla.kernel.org/>
	<20070708152935.b34d6e66.akpm@linux-foundation.org>
	<20070711174511.B1148@jurassic.park.msu.ru>
	<469668B6.7020305@alcatraz.fdf.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Ivan Kokshaysky <ink@jurassic.park.msu.ru>,
	Richard Henderson <rth@twiddle.net>, netdev@vger.kernel.org,
	"bugme-daemon@kernel-bugs.osdl.org"
	<bugme-daemon@kernel-bugs.osdl.org>
To: Dustin Marquess <jailbird@alcatraz.dnsalias.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:52431 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754655AbXGLSbe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jul 2007 14:31:34 -0400
In-Reply-To: <469668B6.7020305@alcatraz.fdf.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 12 Jul 2007 12:45:26 -0500
Dustin Marquess <jailbird@alcatraz.dnsalias.net> wrote:

> Bingo!  That did it.
> 
> I copied/modified the #ifdef from tulip_core.c:
> 
> /* Set the copy breakpoint for the copy-only-tiny-buffer Rx structure. */
> #if defined(__alpha__) || defined(__arm__) || defined(__hppa__) \
>         || defined(CONFIG_SPARC) || defined(__ia64__) \
>         || defined(__sh__) || defined(__mips__)
> static int rx_copybreak = 1518;
> #else
> static int rx_copybreak;
> #endif
> 
> And that seems to have worked like a champ.

Can you send us a patch please?

http://www.zip.com.au/~akpm/linux/patches/stuff/tpp.txt and
http://linux.yyz.us/patch-format.html

contain some guidelines.

Thanks.
