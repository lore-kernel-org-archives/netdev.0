From: Cong Wang <amwang@redhat.com>
Subject: Re: Redefinition of struct in6_addr in <netinet/in.h> and
 <linux/in6.h>
Date: Thu, 17 Jan 2013 14:59:13 +0800
Message-ID: <1358405953.2547.3.camel@cr0>
References: <201301161205.04502.vapier@gentoo.org>
	 <1358356211.2923.25.camel@bwh-desktop.uk.solarflarecom.com>
	 <201301161228.42592.vapier@gentoo.org>
	 <20130116.135959.90676245194307972.davem@davemloft.net>
	 <CANE52KhF17WRZTUbrjRDnwcbdN+V+69=ZqXjBwPjnswEO5iz7g@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, vapier@gentoo.org,
        bhutchings@solarflare.com, libc-alpha@sourceware.org,
        yoshfuji@linux-ipv6.org, tmb@mageia.org, eblake@redhat.com,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        libvirt-list@redhat.com, tgraf@suug.ch, schwab@suse.de,
        carlos@systemhalted.org
To: Jike Song <albcamus@gmail.com>
Return-path: <libc-alpha-return-36357-glibc-alpha=m.gmane.org@sourceware.org>
In-Reply-To: <CANE52KhF17WRZTUbrjRDnwcbdN+V+69=ZqXjBwPjnswEO5iz7g@mail.gmail.com>
List-Unsubscribe: <mailto:libc-alpha-unsubscribe-glibc-alpha=m.gmane.org@sourceware.org>
List-Subscribe: <mailto:libc-alpha-subscribe@sourceware.org>
List-Archive: <http://sourceware.org/ml/libc-alpha/>
List-Post: <mailto:libc-alpha@sourceware.org>
List-Help: <mailto:libc-alpha-help@sourceware.org>, <http://sourceware.org/ml/#faqs>
Sender: libc-alpha-owner@sourceware.org
List-Id: netdev.vger.kernel.org

On Thu, 2013-01-17 at 11:55 +0800, Jike Song wrote:
> On Thu, Jan 17, 2013 at 2:59 AM, David Miller <davem@davemloft.net> wrote:
> 
> >
> > When GLIBC doesn't provide it's own definition of some networking
> > macros or interfaces that the kernel provides, people include the
> > kernel header.
> >
> 
> Recently I got a problem when copying a structure from kernel to userspace,
> after debugging I found:
> 
> kernel:   include/linux/inet.h
> 
> #define INET6_ADDRSTRLEN        (48)
> 
> glibc:  /usr/include/netinet/in.h
> 
> #define INET6_ADDRSTRLEN 46
> 
> 
> Any reason to differentiate them from each other?
> 

I see no reason, even although I don't know why it is 46 instead of 40.

But include/linux/inet.h is not exported to user-space, AFAIK.
