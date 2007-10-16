From: Jean Delvare <khali@linux-fr.org>
Subject: Re: [PATCH] Update function names in /proc/net/tcp documentation
Date: Tue, 16 Oct 2007 10:46:36 +0200
Message-ID: <20071016104636.7d633bad@hyperion.delvare>
References: <20071014115934.13530a8a@hyperion.delvare>
	<E1Ih0PI-0003TX-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: rick.jones2@hp.com, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-102-tuesday.nerim.net ([62.4.16.102]:63153 "EHLO
	kraid.nerim.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1751558AbXJPIqj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Oct 2007 04:46:39 -0400
In-Reply-To: <E1Ih0PI-0003TX-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Herbert,

On Sun, 14 Oct 2007 18:09:12 +0800, Herbert Xu wrote:
> Jean Delvare <khali@linux-fr.org> wrote:
> >
> >> inet_diag is the preferred interface.
> > 
> > How does it work? Is there some documentation available? I see
> > net/ipv4/inet_diag.c but I have no idea how to use it.
> 
> Have a look at the iproute package.  It contains the ss command
> which provides a command-line interface to it.
> 
> Of course it's also a good example of how you can access it from
> C.  The Debian pidentd package has also been patched to use this
> interface.

Thanks for the information. Now I'm worried that most people use
netstat and not ss, while it seems that netstat doesn't have tcp_diag
support. Would it make sense to add tcp_diag support to netstat? Or
should we simply invite system admins to switch from netstat to ss
(maybe by adding a netstat-like formatting option)?

Not that I am skilled enough in this area to do either myself anyway
(let alone the lack of time), but I'm curious what the correct approach
would be.

Thanks,
-- 
Jean Delvare
