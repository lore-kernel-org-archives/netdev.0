From: Jeff Chua <jeffchua@silk.corp.fedex.com>
Subject: Re: [ANNOUNCE] iproute2 2.6.9-041019
Date: Thu, 21 Oct 2004 10:53:12 +0800 (SGT)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <Pine.LNX.4.61.0410211049400.4927@boston.corp.fedex.com>
References: <41758014.4080502@osdl.org> <Pine.LNX.4.61.0410200805110.8475@boston.corp.fedex.com>
 <20041020091554.57e60936@zqx3.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: Jeff Chua <jeffchua@silk.corp.fedex.com>,
        Linux Kernel <linux-kernel@vger.kernel.org>, netdev@oss.sgi.com,
        linux-net@vger.kernel.org, LARTC@mailman.ds9a.nl
Return-path: <netdev-bounce@oss.sgi.com>
To: Stephen Hemminger <shemminger@osdl.org>
In-Reply-To: <20041020091554.57e60936@zqx3.pdx.osdl.net>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org


On Wed, 20 Oct 2004, Stephen Hemminger wrote:

> Try this, ss was dragging in byteorder.h and it didn't need to.
>
> diff -Nru a/misc/ss.c b/misc/ss.c
> --- a/misc/ss.c	2004-10-20 09:13:56 -07:00
> +++ b/misc/ss.c	2004-10-20 09:13:56 -07:00
> @@ -33,7 +33,6 @@
> #include "libnetlink.h"
> #include "SNAPSHOT.h"
>
> -#include <asm/byteorder.h>
> #include <linux/tcp.h>
> #include <linux/tcp_diag.h>


same problem.

"#include <linux/tcp.h>" is dragging in "#include <asm/byteorder.h>".

Same thing goes for <linux/ip.h>.

All these kernel headers need cleanup, and I don't know enough to fix it.

Jeff.
