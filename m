From: "David S. Miller" <davem@redhat.com>
Subject: Re: /usr/src/linux/Documentation/networking/ifenslave.c
Date: Wed, 16 Jul 2003 05:42:55 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030716054255.1922d299.davem@redhat.com>
References: <20030716092354.GC24077@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Mads Martin =?ISO-8859-1?Q?J=F8rgensen?= <mmj@suse.de>
In-Reply-To: <20030716092354.GC24077@suse.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 16 Jul 2003 11:23:54 +0200
Mads Martin J=F8rgensen <mmj@suse.de> wrote:

> $SUBJECT is a userspace tool, but includes kernel headers. This small
> obvious patch against 2.6.0-test1 should fix it.

This patch is absolutely senseless, you eliminate two such includes

> -#include <linux/if.h>
> -#include <linux/if_arp.h>
> +#include <net/if_arp.h>

but three more still remain.

>  #include <linux/if_ether.h>
>  #include <linux/if_bonding.h>
>  #include <linux/sockios.h>

This whole anti-kernel-headers-in-userspace thing is a
total shamans dance and not founded in reality.

Quick, answer this as fast as you can, where in the glibc headers can
you get at the PFKEY and XFRM_NETLINK interface definitions to
configure IPSEC stuff in the kernel?

BZZT, time is up, and I know you have no answer :-)

That is why all of this is rediculious.
