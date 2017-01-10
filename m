From: Arnd Bergmann <arnd@arndb.de>
Subject: Re: linux-next: manual merge of the y2038 tree with the net-next tree
Date: Tue, 10 Jan 2017 11:06:22 +0100
Message-ID: <CAK8P3a2U5=LGWkLY6jCdfsoAAshc7ggL15Uao_Y1rwdwVNf0oA@mail.gmail.com>
References: <20170110135201.2a62a4d9@canb.auug.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem@davemloft.net>,
        Networking <netdev@vger.kernel.org>, linux-next@vger.kernel.org,
        linux-kernel@vger.kernel.org, David Howells <dhowells@redhat.com>,
        Tina Ruchandani <ruchandani.tina@gmail.com>
To: Stephen Rothwell <sfr@canb.auug.org.au>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170110135201.2a62a4d9@canb.auug.org.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hmm, I thought I had removed that commit when you asked me about it
last week. I've done it now, the conflict should be gone tomorrow.

On Tue, Jan 10, 2017 at 3:52 AM, Stephen Rothwell <sfr@canb.auug.org.au> wrote:
> Hi Arnd,
>
> Today's linux-next merge of the y2038 tree got a conflict in:
>
>   fs/afs/main.c
>
> between commit:
>
>   8e8d7f13b6d5 ("afs: Add some tracepoints")
>
> from the net-next tree and commit:
>
>   549eb7b22e24 ("AFS: Correctly use 64-bit time for UUID")
>
> from the y2038 tree.
>
> I fixed it up (see below) and can carry the fix as necessary. This
> is now fixed as far as linux-next is concerned, but any non trivial
> conflicts should be mentioned to your upstream maintainer when your tree
> is submitted for merging.  You may also want to consider cooperating
> with the maintainer of the conflicting tree to minimise any particularly
> complex conflicts.
>
> --
> Cheers,
> Stephen Rothwell
>
> diff --cc fs/afs/main.c
> index f8188feb03ad,129ff432391c..000000000000
> --- a/fs/afs/main.c
> +++ b/fs/afs/main.c
> @@@ -14,8 -14,7 +14,9 @@@
>   #include <linux/init.h>
>   #include <linux/completion.h>
>   #include <linux/sched.h>
>  +#include <linux/random.h>
>  +#define CREATE_TRACE_POINTS
> + #include <linux/ktime.h>
>   #include "internal.h"
>
>   MODULE_DESCRIPTION("AFS Client File System");
