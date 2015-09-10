From: David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
Subject: Re: [PATCH] Remove #ifdef CONFIG_64BIT from all asm-generic/fcntl.h
Date: Thu, 10 Sep 2015 12:18:05 +0100
Message-ID: <18247.1441883885@warthog.procyon.org.uk>
References: <18147.1441883729@warthog.procyon.org.uk> <1441832902-28993-1-git-send-email-palmer@dabbelt.com> <2644177.lVCYzIBfPW@wuerfel>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, arnd-r2nGTMty4D4@public.gmane.org, 3chas3-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org,
	hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org, mingo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org, plagnioj-sclMFOaUSTBWk0Htik3J/w@public.gmane.org,
	jikos-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-arch-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-atm-general-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org,
	linux-fbdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, tglx-hfZtesqFncYOwBW4kG4KsQ@public.gmane.org, tomi.valkeinen-l0cyMroinI0@public.gmane.org,
	x86-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org
To: Palmer Dabbelt <palmer-96lFi9zoCfxBDgjK7y7TUQ@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <18147.1441883729-S6HVgzuS8uM4Awkfq6JHfwNdhmdF6hFW@public.gmane.org>
Content-ID: <18246.1441883885.1-S6HVgzuS8uM4Awkfq6JHfwNdhmdF6hFW@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

David Howells <dhowells-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org> wrote:

> Rather than iterating through all the rest of your patches and saying the same
> thing, if there's something in a UAPI header that needs wrapping in __KERNEL__
> to exclude it from userspace's use, then it should be transferred to the
> non-UAPI variant of that header (which should #include the UAPI variant).

I should mention that there is the odd case where this is difficult to
achieve.  See include/uapi/linux/acct.h for an example...

David
