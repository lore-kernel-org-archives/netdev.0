From: Bart Van Assche <bvanassche-HInyCGIudOg@public.gmane.org>
Subject: Re: [RFC 1/3] RDMA: Add netlink infrastructure
Date: Fri, 13 May 2011 19:18:45 +0200
Message-ID: <BANLkTikpzn6R-QH__dtmwz=fO1QMUN+qag@mail.gmail.com>
References: <1305303525-11113-1-git-send-email-roland@kernel.org>
 <1305303525-11113-2-git-send-email-roland@kernel.org> <1305305065.8178.9.camel@Joe-Laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Roland Dreier <roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>, Nir Muchtar <nirm-smomgflXvOZWk0Htik3J/w@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1305305065.8178.9.camel@Joe-Laptop>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, May 13, 2011 at 6:44 PM, Joe Perches <joe-6d6DIl74uiNBDgjK7y7TUQ@public.gmane.org> wrote:
> On Fri, 2011-05-13 at 09:18 -0700, Roland Dreier wrote:
>> From: Roland Dreier <roland-BHEL68pLQRGGvPXPguhicg@public.gmane.org>
>> [Dave please do not apply even if this ends up in netdev patchwork!]
>
> Just trivia:
>
>> diff --git a/drivers/infiniband/core/netlink.c b/drivers/infiniband/=
core/netlink.c
> []
>> +#define pr_fmt(fmt) "%s:%s: " fmt, KBUILD_MODNAME, __func__
>
> Using #define pr_fmt(fmt) KBUILD_MODNAME ":%s: " fmt, __func__
> generally produces smaller overall object size, especially
> at 64 bit.
>
> For instance, here's the size of netlink.o at 32 bit:
>
> $ size drivers/infiniband/core/netlink.o.*
> =A0 text =A0 =A0data =A0 =A0 bss =A0 =A0 dec =A0 =A0 hex filename
> =A0 2663 =A0 =A0 153 =A0 =A0 736 =A0 =A03552 =A0 =A0 de0 drivers/infi=
niband/core/netlink.o.old
> =A0 2640 =A0 =A0 153 =A0 =A0 736 =A0 =A03529 =A0 =A0 dc9 drivers/infi=
niband/core/netlink.o.new
>
> Also, I rarely find __func__ useful in message output.
> It may be more useful for active development/debugging.

A recent dynamic debug patch made it possible to enable/disable at
runtime whether or not the function name (and more) should be included
in the output. See also http://lwn.net/Articles/434833/ for more
information.

Bart.
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" i=
n
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
