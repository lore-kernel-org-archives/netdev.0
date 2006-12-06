From: Thomas Graf <tgraf@suug.ch>
Subject: Re: Kernel header changes break glibc build
Date: Wed, 6 Dec 2006 21:26:39 +0100
Message-ID: <20061206202639.GG8693@postel.suug.ch>
References: <Pine.LNX.4.64.0610061718370.18057@digraph.polyomino.org.uk> <1165148731.12649.51.camel@pmac.infradead.org> <20061204091341.GM8693@postel.suug.ch> <1165410114.5253.218.camel@pmac.infradead.org> <20061206134308.GL9556@sunsite.mff.cuni.cz> <20061206135931.GB8693@postel.suug.ch> <1165414039.5253.233.camel@pmac.infradead.org> <20061206141841.GN9556@sunsite.mff.cuni.cz> <20061206143146.GD8693@postel.suug.ch> <20061206171336.GB4587@ftp.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jakub Jelinek <jakub@redhat.com>,
	David Woodhouse <dwmw2@infradead.org>,
	Ulrich Drepper <drepper@redhat.com>,
	"Joseph S. Myers" <joseph@codesourcery.com>,
	netdev@vger.kernel.org, libc-alpha@sourceware.org, akpm@osdl.org,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:49670 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S937616AbWLFU0T (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Dec 2006 15:26:19 -0500
To: Al Viro <viro@ftp.linux.org.uk>
Content-Disposition: inline
In-Reply-To: <20061206171336.GB4587@ftp.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Al Viro <viro@ftp.linux.org.uk> 2006-12-06 17:13
> On Wed, Dec 06, 2006 at 03:31:46PM +0100, Thomas Graf wrote:
>  
> > At the time they were added they were meant to be exported but netlink
> > has evolved and we now have a type safe API.
> 
> Where?  AFAICS, netlink might be considered type-safe only within an
> address family...

The new interface can be found in net/netlink.h, it obsoletes the
old interface which is spread over linux/netlink.h and linux/rtnetlink.h

I'm removing the old bits as soon as I've finished converting all
its users.

An almost identical interface is provided to userspace by libnl.
