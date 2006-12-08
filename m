From: Daniel Jacobowitz <drow@false.org>
Subject: Re: [NETLINK]: Restore API compatibility of address and neighbour bits
Date: Fri, 8 Dec 2006 16:52:06 -0500
Message-ID: <20061208215206.GA29601@nevyn.them.org>
References: <200612081526.12651.stefan@loplof.de> <20061208.133334.55725556.davem@davemloft.net> <20061208213614.GA28903@nevyn.them.org> <20061208.134752.131916271.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: stefan@loplof.de, tgraf@suug.ch, dwmw2@infradead.org,
	joseph@codesourcery.com, netdev@vger.kernel.org,
	libc-alpha@sourceware.org, akpm@osdl.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from nevyn.them.org ([66.93.172.17]:56299 "EHLO nevyn.them.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1947404AbWLHVwO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 8 Dec 2006 16:52:14 -0500
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <20061208.134752.131916271.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Dec 08, 2006 at 01:47:52PM -0800, David Miller wrote:
> > > > The _RTA and _PAYLOAD-macros are also part of userspace headers and need to be
> > > > restored. Both dhcpclient and quagga need at least IFA_RTA and IFLA_RTA to
> > > > compile, but there may be more macros than in the following patch. You may want
> > > > to look at keepalived, iproute, ...

> GLIBC does not use them.

Aren't these the ones you're talking about?

sysdeps/unix/sysv/linux/check_pf.c:                   struct rtattr *rta = IFA_RTA (ifam);
sysdeps/unix/sysv/linux/if_index.c:           struct rtattr *rta = IFLA_RTA (ifim);
sysdeps/unix/sysv/linux/ifaddrs.c:            struct rtattr *rta = IFLA_RTA (ifim);
sysdeps/unix/sysv/linux/ifaddrs.c:            struct rtattr *rta = IFLA_RTA (ifim);
sysdeps/unix/sysv/linux/ifaddrs.c:            struct rtattr *rta = IFA_RTA (ifam);

sysdeps/unix/sysv/linux/if_index.c:           size_t rtasize = IFLA_PAYLOAD (nlh);
sysdeps/unix/sysv/linux/if_index.c:               size_t rta_payload = RTA_PAYLOAD (rta);
sysdeps/unix/sysv/linux/ifaddrs.c:            size_t rtasize = IFLA_PAYLOAD (nlh);
sysdeps/unix/sysv/linux/ifaddrs.c:                size_t rta_payload = RTA_PAYLOAD (rta);
sysdeps/unix/sysv/linux/ifaddrs.c:            size_t rtasize = IFLA_PAYLOAD (nlh);
sysdeps/unix/sysv/linux/ifaddrs.c:                size_t rta_payload = RTA_PAYLOAD (rta);
sysdeps/unix/sysv/linux/ifaddrs.c:            size_t rtasize = IFA_PAYLOAD (nlh);
sysdeps/unix/sysv/linux/ifaddrs.c:                size_t rta_payload = RTA_PAYLOAD (rta);

-- 
Daniel Jacobowitz
CodeSourcery
