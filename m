From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/1 net-next] net/core: include linux/types.h instead of
 asm/types.h
Date: Mon, 17 Nov 2014 14:05:56 -0800
Message-ID: <1416261956.18588.9.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1416258502-9001-1-git-send-email-fabf@skynet.be>
	 <1416259376.18588.8.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20141117.163532.788436432373669437.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: fabf@skynet.be, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141117.163532.788436432373669437.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 2014-11-17 at 16:35 -0500, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Mon, 17 Nov 2014 13:22:56 -0800
> 
> > On Mon, 2014-11-17 at 22:08 +0100, Fabian Frederick wrote:
> >> Signed-off-by: Fabian Frederick <fabf@skynet.be>
> >> ---
> >>  net/core/link_watch.c | 2 +-
> >>  1 file changed, 1 insertion(+), 1 deletion(-)
> >> 
> >> diff --git a/net/core/link_watch.c b/net/core/link_watch.c
> >> index bd0767e..49a9e3e 100644
> >> --- a/net/core/link_watch.c
> >> +++ b/net/core/link_watch.c
> >> @@ -21,7 +21,7 @@
> >>  #include <linux/spinlock.h>
> >>  #include <linux/workqueue.h>
> >>  #include <linux/bitops.h>
> >> -#include <asm/types.h>
> >> +#include <linux/types.h>
> >>  
> > 
> > We have 99 such occurrences in net/
> > 
> > Are you going to send 99 patches ?
> 
> Yeah, probably best to consolidate into one or a few patches.

BTW the 99 occurrences are for asm/uaccess.h, it seems I gave the reply
on the wrong patch.
