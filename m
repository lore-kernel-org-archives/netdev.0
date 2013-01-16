From: David Miller <davem@davemloft.net>
Subject: Re: Redefinition of struct in6_addr in <netinet/in.h> and
 <linux/in6.h>
Date: Wed, 16 Jan 2013 13:57:44 -0500 (EST)
Message-ID: <20130116.135744.697469565804508454.davem@davemloft.net>
References: <50F6B761.8070106@linux-ipv6.org>
	<1358351232.2923.10.camel@bwh-desktop.uk.solarflarecom.com>
	<201301161205.04502.vapier@gentoo.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: libc-alpha@sourceware.org, bhutchings@solarflare.com,
 yoshfuji@linux-ipv6.org, amwang@redhat.com, tmb@mageia.org,
 eblake@redhat.com, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
 libvirt-list@redhat.com, tgraf@suug.ch, schwab@suse.de,
 carlos@systemhalted.org
To: vapier@gentoo.org
Return-path: <libc-alpha-return-36294-glibc-alpha=m.gmane.org@sourceware.org>
In-Reply-To: <201301161205.04502.vapier@gentoo.org>
List-Unsubscribe: <mailto:libc-alpha-unsubscribe-glibc-alpha=m.gmane.org@sourceware.org>
List-Subscribe: <mailto:libc-alpha-subscribe@sourceware.org>
List-Archive: <http://sourceware.org/ml/libc-alpha/>
List-Post: <mailto:libc-alpha@sourceware.org>
List-Help: <mailto:libc-alpha-help@sourceware.org>, <http://sourceware.org/ml/#faqs>
Sender: libc-alpha-owner@sourceware.org
List-Id: netdev.vger.kernel.org

From: Mike Frysinger <vapier@gentoo.org>
Date: Wed, 16 Jan 2013 12:04:56 -0500

> certainly true, but the current expectation is that you don't mix your ABIs.  
> if you're programming with the C library API, then use the C library headers.  
> if you're banging directly on the kernel, then use the kernel headers.  not 
> saying it's a perfect solution, but it works for the vast majority of use 
> cases.

This isn't how real life works.

GLIBC itself brings in some of the kernel headers, as do various library
headers for libraries other than glibc.

So you can get these conflicting headers included indirectly, and it is
of no fault of any of the various parties involved.

We have to make them work when included at the same time somehow, and
this is totally unavoidable.
