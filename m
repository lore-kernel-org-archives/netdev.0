From: "David S. Miller" <davem@redhat.com>
Subject: Re: /usr/src/linux/Documentation/networking/ifenslave.c
Date: Wed, 16 Jul 2003 06:28:33 -0700
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20030716062833.2c25906f.davem@redhat.com>
References: <20030716092354.GC24077@suse.de>
	<20030716054255.1922d299.davem@redhat.com>
	<20030716125910.GB10817@suse.de>
	<20030716061013.64f14a04.davem@redhat.com>
	<20030716133514.GB7184@suse.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Mads Martin =?ISO-8859-1?Q?J=F8rgensen?= <mmj@suse.de>
In-Reply-To: <20030716133514.GB7184@suse.de>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On Wed, 16 Jul 2003 15:35:14 +0200
Mads Martin J=F8rgensen <mmj@suse.de> wrote:

> * David S. Miller <davem@redhat.com> [Jul 16. 2003 15:21]:
> In file included from /usr/src/linux/include/asm/system.h:19,
>                  from /usr/src/linux/include/asm/atomic.h:17,
>                  from /usr/src/linux/include/linux/netdevice.h:32,
>                  from /usr/src/linux/include/linux/if_arp.h:26,
>                  from ifenslave.c:91:
> /usr/src/linux/include/asm/pal.h:89: parse error before "pal_status_t"

IA64 needs it's __KERNEL__ ifdefs fixed up, nothing more.

Thanks for finding the right place to fix this problem :-)
