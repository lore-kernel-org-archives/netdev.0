From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH/RFC] iproute2: drop libresolv
Date: Mon, 12 Nov 2012 08:51:15 -0800
Message-ID: <20121112085115.04ea916c@nehalam.linuxnetplumber.net>
References: <20121110122209.GA15100@amd64.fatal.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Andreas Henriksson <andreas@fatal.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:49555 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753804Ab2KLQwR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Nov 2012 11:52:17 -0500
In-Reply-To: <20121110122209.GA15100@amd64.fatal.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 10 Nov 2012 13:22:10 +0100
Andreas Henriksson <andreas@fatal.se> wrote:

> Hello!
> 
> While building the iproute package in Debian I get warnings from
> package helpers like this:
> 
> dpkg-shlibdeps: warning: package could avoid a useless dependency if debian/iproute/sbin/tc debian/iproute/usr/bin/lnstat debian/iproute/bin/ip debian/iproute/bin/ss debian/iproute/sbin/bridge debian/iproute/sbin/rtmon were not linked against libresolv.so.2 (they use none of the library's symbols)
> 
> The -lresolv in ./Makefile seems to come from pre-historic times (before
> iproute2 git history, possibly from libc5/pre-glibc days).
> I couldn't find out if/why there was any reason for linking to libresolv.
> Does anyone know if there are any valid reasons for keeping it still?
> 
> If not, I'd be happy to see it go.... while at it I also removed includes
> of <resolv.h> which I also couldn't find any reason for, but this is
> just an added bonus of the patch (and there are probably more unneeded
> includes that could be dropped in the same sources).
> 
> 
> Signed-off-by: Andreas Henriksson <andreas@fatal.se>
> 

Makes sense, applied.
