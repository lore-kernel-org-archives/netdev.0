From: Thomas Graf <tgraf@suug.ch>
Subject: Re: Kernel header changes break glibc build
Date: Wed, 6 Dec 2006 21:22:36 +0100
Message-ID: <20061206202236.GF8693@postel.suug.ch>
References: <Pine.LNX.4.64.0610061718370.18057@digraph.polyomino.org.uk> <1165148731.12649.51.camel@pmac.infradead.org> <20061204091341.GM8693@postel.suug.ch> <200612062033.34754.stefan@loplof.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Woodhouse <dwmw2@infradead.org>,
	"Joseph S. Myers" <joseph@codesourcery.com>,
	netdev@vger.kernel.org, libc-alpha@sourceware.org, akpm@osdl.org,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from postel.suug.ch ([194.88.212.233]:49632 "EHLO postel.suug.ch"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S937613AbWLFUWQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Dec 2006 15:22:16 -0500
To: Stefan Rompf <stefan@loplof.de>
Content-Disposition: inline
In-Reply-To: <200612062033.34754.stefan@loplof.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

* Stefan Rompf <stefan@loplof.de> 2006-12-06 20:32
> According to a user's report, your change also broke compilation of my 
> dhcpclient because it neeeds if_addr.h since 2.6.19. Any suggestion how to 
> make one source code build on 2.6.19 and older headers? I hope you don't want 
> me to check on UTS_RELEASE in a userspace program?

#ifndef IFA_MAX
#include <linux/if_addr.h>
#endif
