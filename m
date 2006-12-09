From: David Miller <davem@davemloft.net>
Subject: Re: [NETLINK]: Schedule removal of old macros exported to userspace
Date: Sat, 09 Dec 2006 13:50:30 -0800 (PST)
Message-ID: <20061209.135030.112606922.davem@davemloft.net>
References: <200612091249.39302.stefan@loplof.de>
	<20061209125533.GO8693@postel.suug.ch>
	<200612091559.05232.stefan@loplof.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tgraf@suug.ch, drow@false.org, dwmw2@infradead.org,
	joseph@codesourcery.com, netdev@vger.kernel.org,
	libc-alpha@sourceware.org, akpm@osdl.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35464
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1758414AbWLIVu3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Dec 2006 16:50:29 -0500
To: stefan@loplof.de
In-Reply-To: <200612091559.05232.stefan@loplof.de>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stefan Rompf <stefan@loplof.de>
Date: Sat, 9 Dec 2006 15:58:01 +0100 (MET)

> But when even glibc needs internal compat headers to compile with the second 
> kernel version that provides userspace headers, what is the long-term - even 
> mid-term - perspective of make headers_install then?

Relax Stefan, I'll make sure these macros never go away.

They may emit warnings, via __attribute__((deprecated)), at
some point, but they will never be flat out removed.
