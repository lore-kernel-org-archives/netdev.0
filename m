From: David Miller <davem@davemloft.net>
Subject: Re: Redefinition of struct in6_addr in <netinet/in.h> and
 <linux/in6.h>
Date: Thu, 17 Jan 2013 23:55:24 -0500 (EST)
Message-ID: <20130117.235524.2010232687612037902.davem@davemloft.net>
References: <1358351232.2923.10.camel@bwh-desktop.uk.solarflarecom.com>
	<20130116.164511.2027039182184636075.davem@davemloft.net>
	<201301172314.34193.vapier@gentoo.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: libc-alpha@sourceware.org, bhutchings@solarflare.com,
 yoshfuji@linux-ipv6.org, amwang@redhat.com, tmb@mageia.org,
 eblake@redhat.com, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
 libvirt-list@redhat.com, tgraf@suug.ch, schwab@suse.de,
 carlos@systemhalted.org
To: vapier@gentoo.org
Return-path: <libc-alpha-return-36401-glibc-alpha=m.gmane.org@sourceware.org>
In-Reply-To: <201301172314.34193.vapier@gentoo.org>
List-Unsubscribe: <mailto:libc-alpha-unsubscribe-glibc-alpha=m.gmane.org@sourceware.org>
List-Subscribe: <mailto:libc-alpha-subscribe@sourceware.org>
List-Archive: <http://sourceware.org/ml/libc-alpha/>
List-Post: <mailto:libc-alpha@sourceware.org>
List-Help: <mailto:libc-alpha-help@sourceware.org>, <http://sourceware.org/ml/#faqs>
Sender: libc-alpha-owner@sourceware.org
List-Id: netdev.vger.kernel.org

From: Mike Frysinger <vapier@gentoo.org>
Date: Thu, 17 Jan 2013 23:14:31 -0500

> the kernel already exports many types with a __kernel_ prefix.  i changed the 
> kernel headers in Gentoo for a few releases (2.6.28 - 2.6.34) to do the same 
> thing to pretty much all the networking headers.  a few packages broke, but 
> the number was low, and trivial to fix (a sed would do it most of the time).
> 
> it's also trivial for userland packages to detect that they need to do this 
> sort of thing in a local header by using linux/version.h and a set of defines 
> to redirect the new structure name back to the old one.
> 
> would be a lot cleaner to just break it and be done.

We are not at liberty to break something that has legitimately
compiled successfully for two decades.

Your __kernel_ prefix idea breaks compilation just as equally.

One thing you certainly don't have to be is happy about this header
file situation, but you cannot use that dissatisfaction as
justification to make the situation worse by breaking the build for
people outside of the world you directly control.
