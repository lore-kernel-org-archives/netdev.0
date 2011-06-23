From: Mike Frysinger <vapier.adi@gmail.com>
Subject: Re: linux-next: Tree for June 23 (net/can & i/o)
Date: Thu, 23 Jun 2011 16:38:56 -0400
Message-ID: <BANLkTi=ZxHDvhCs8Qki2ZrhCbfY6Mjx5+w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-next@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>
To: netdev <netdev@vger.kernel.org>, socketcan-core@lists.berlios.de
Return-path: <linux-next-owner@vger.kernel.org>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Jun 23, 2011 at 01:54, Stephen Rothwell <sfr@canb.auug.org.au> wrote:
> My fixes tree includes (as an experiment) the early part of
> mmotm-2011-06-22-13-05.
>
> The powerpc allyesconfig (and probably others) is still broken because we
> now build the staging drivers and because of a commit in the net tree.
> The breakage in Linus' tree is fixed by one of Andrew's patches above.
>
> The m68knommu tree lost its conflicts.
>
> The galak tree lost its conflicts.
>
> The net tree gained 2 build failures that I have left (see above).

not sure where this is coming from, but some Blackfin boards now fail with:

drivers/net/can/bfin_can.c: In function 'bfin_can_start_xmit':
drivers/net/can/bfin_can.c:247: error: implicit declaration of function 'writew'
make[3]: *** [drivers/net/can/bfin_can.o] Error 1

at any rate, the usage of writew() in this driver is wrong, so i sent
a patch to fix it.  but since nothing in this file nor in my Blackfin
tree changed, i wonder if whatever common code changed is going to
break other stuff ...
-mike
