From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: + net-ipv4-tcpc-fix-warning.patch added to -mm tree
Date: Tue, 8 Dec 2009 18:08:01 -0800
Message-ID: <20091208180801.88be28ba.akpm@linux-foundation.org>
References: <200912090045.nB90jTaO010647@imap1.linux-foundation.org>
	<4B1F0151.10903@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: William Allen Simpson <william.allen.simpson@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1.linux-foundation.org ([140.211.169.13]:60791 "EHLO
	smtp1.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753529AbZLICH5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Dec 2009 21:07:57 -0500
In-Reply-To: <4B1F0151.10903@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 08 Dec 2009 20:45:53 -0500
William Allen Simpson <william.allen.simpson@gmail.com> wrote:

> > ------------------------------------------------------
> > Subject: net/ipv4/tcp.c: fix warning
> > From: Andrew Morton <akpm@linux-foundation.org>
> > 
> > x86_64 allmodconfig:
> > 
> > net/ipv4/tcp.c: In function 'do_tcp_getsockopt':
> > net/ipv4/tcp.c:2544: warning: comparison is always false due to limited range of data type
> > 
> > sizeof(tcpct_value) is 536, which can never be less than a value which is held
> > in a u8.
> > 
> > This fix is stupid - just delete the code?
> > 
> I didn't have this warning, how in the world do you get it?

Used gcc-4.0.2.  They re-randomise the warnings with each release I think.

> This is what David calls my "anal" coding style.  I check everything,
> because someday somebody else might make a change, and it's important
> that such problems be detected.  In this case, I assume the compiler
> will compile them out or it would have no effect, and commented that
> it should be impossible.
> 
> Your test should probably be TCP_MSS_DEFAULT < TCP_COOKIE_PAIR_SIZE

I'd say just delete it ;)

