From: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Subject: Re: [PATCH] bridge: include in6.h in if_bridge.h for struct
 in6_addr
Date: Wed, 05 Nov 2014 17:13:48 -0500 (EST)
Message-ID: <20141105.171348.1010570676094960613.davem@davemloft.net>
References: <1415128881-30183-1-git-send-email-gregory.0xf0@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, carlos-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, eblake-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	galak-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org, f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	xiyou.wangcong-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
To: gregory.0xf0-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1415128881-30183-1-git-send-email-gregory.0xf0-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Gregory Fong <gregory.0xf0-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Date: Tue,  4 Nov 2014 11:21:21 -0800

> if_bridge.h uses struct in6_addr ip6, but wasn't including the in6.h
> header.  Thomas Backlund originally sent a patch to do this, but this
> revealed a redefinition issue: https://lkml.org/lkml/2013/1/13/116
> 
> The redefinition issue should have been fixed by the following Linux
> commits:
> ee262ad827f89e2dc7851ec2986953b5b125c6bc inet: defines IPPROTO_* needed for module alias generation
> cfd280c91253cc28e4919e349fa7a813b63e71e8 net: sync some IP headers with glibc
> 
> and the following glibc commit:
> 6c82a2f8d7c8e21e39237225c819f182ae438db3 Coordinate IPv6 definitions for Linux and glibc
> 
> so actually include the header now.
> 
> Reported-by: Colin Guthrie <colin-odJJhXpcy38dnm+yROfE0A@public.gmane.org>
> Reported-by: Christiaan Welvaart <cjw-CllfUmslCRwdbCeoMzGj59i2O/JbrIOy@public.gmane.org>
> Reported-by: Thomas Backlund <tmb-odJJhXpcy38dnm+yROfE0A@public.gmane.org>
> Cc: Florian Fainelli <f.fainelli-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> Cc: Cong Wang <xiyou.wangcong-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
> Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
> Signed-off-by: Gregory Fong <gregory.0xf0-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>

Applied, thank you.
