From: David Woodhouse <dwmw2@infradead.org>
Subject: Re: [NETLINK]: Schedule removal of old macros exported to userspace
Date: Tue, 12 Dec 2006 11:23:51 +0000
Message-ID: <1165922631.5253.623.camel@pmac.infradead.org>
References: <20061208.134752.131916271.davem@davemloft.net>
	 <200612091249.39302.stefan@loplof.de>
	 <20061209125533.GO8693@postel.suug.ch>
	 <200612091559.05232.stefan@loplof.de>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Thomas Graf <tgraf@suug.ch>, David Miller <davem@davemloft.net>,
	drow@false.org, joseph@codesourcery.com, netdev@vger.kernel.org,
	libc-alpha@sourceware.org, akpm@osdl.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:36436 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932199AbWLLLZN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 12 Dec 2006 06:25:13 -0500
To: Stefan Rompf <stefan@loplof.de>
In-Reply-To: <200612091559.05232.stefan@loplof.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2006-12-09 at 15:58 +0100, Stefan Rompf wrote:
> But when even glibc needs internal compat headers to compile with the second 
> kernel version that provides userspace headers, what is the long-term - even 
> mid-term - perspective of make headers_install then?

Bear in mind that with the first cut of the headers_install I was trying
to keep it entirely uncontentious and stick to _mechanism_, not policy.
The _first_ set of exported headers still aren't ideal, and we're still
cleaning up some parts of them (like properly getting rid of the
_syscallX() macros, etc.). 

We've only just started to be sensible about what we export to userspace
-- it's not entirely set in stone at this point, 
 
-- 
dwmw2

