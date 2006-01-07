From: Joe Kappus <joecool1029@gmail.com>
Subject: Re: [2.6 patch] fix ipvs compilation
Date: Fri, 6 Jan 2006 22:30:56 -0500
Message-ID: <d4757e600601061930v3fc113c1t9d71c951613abf09@mail.gmail.com>
References: <20060105135943.GA3831@stusta.de>
	 <d4757e600601052043u647658f1yaa15b0f396b4ad3c@mail.gmail.com>
	 <20060106.131536.88566896.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: bunk@stusta.de, wensong@linux-vs.org, horms@verge.net.au,
	ja@ssi.bg, netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1030332AbWAGDbE@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
In-Reply-To: <20060106.131536.88566896.davem@davemloft.net>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 1/6/06, David S. Miller <davem@davemloft.net> wrote:
> From: Joe <joecool1029@gmail.com>
> Date: Thu, 5 Jan 2006 23:43:52 -0500
>
> > Thats not all either,  ./net/ipv4/netfilter/ipt_helper.c has the same
> > error and the same fix.
> >
> > Here's the patch for this one.  Sorry for the dupe.. i sent the last
> > as html by accident.
>
> Applied, please provide a "Signed-off-by:" line with your patch
> next time.
>
> Thanks.
>

Why not then, we'll do this one as well since it needs it.

Signed-off-by: Joe Kappus <joecool1029@gmail.com>

--- ./net/ipv4/netfilter/ip_conntrack_proto_sctp.c.old  2006-01-06
22:27:08.885583023 -0500
+++ ./net/ipv4/netfilter/ip_conntrack_proto_sctp.c      2006-01-06
22:27:44.606582972 -0500
@@ -16,6 +16,7 @@
 #include <linux/types.h>
 #include <linux/sched.h>
 #include <linux/timer.h>
+#include <linux/interrupt.h>
 #include <linux/netfilter.h>
 #include <linux/module.h>
 #include <linux/in.h>
