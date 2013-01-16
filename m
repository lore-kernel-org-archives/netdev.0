From: David Miller <davem@davemloft.net>
Subject: Re: Redefinition of struct in6_addr in <netinet/in.h> and
 <linux/in6.h>
Date: Wed, 16 Jan 2013 13:59:59 -0500 (EST)
Message-ID: <20130116.135959.90676245194307972.davem@davemloft.net>
References: <201301161205.04502.vapier@gentoo.org>
	<1358356211.2923.25.camel@bwh-desktop.uk.solarflarecom.com>
	<201301161228.42592.vapier@gentoo.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: bhutchings@solarflare.com, libc-alpha@sourceware.org,
	yoshfuji@linux-ipv6.org, amwang@redhat.com, tmb@mageia.org,
	eblake@redhat.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, libvirt-list@redhat.com,
	tgraf@suug.ch, schwab@suse.de, carlos@systemhalted.org
To: vapier@gentoo.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <201301161228.42592.vapier@gentoo.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Mike Frysinger <vapier@gentoo.org>
Date: Wed, 16 Jan 2013 12:28:39 -0500

> if you're not calling the kernel directly, why are you including the kernel 
> headers ?  what is the problem people are actually trying to address here (and 
> no, "i want to include both headers" is not the answer) ?

When GLIBC doesn't provide it's own definition of some networking
macros or interfaces that the kernel provides, people include the
kernel header.

This has been done for decades, wake up.
