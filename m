From: "Ian Brown" <ianbrn@gmail.com>
Subject: Re: [RFC][PATCH] trivial typo correction in net/ipv4/xfrm4_policy.c
Date: Tue, 18 Sep 2007 09:46:15 +0200
Message-ID: <d0383f90709180046t35a1262ax124da0776c89e0bd@mail.gmail.com>
References: <d0383f90709170050k3694b52id8fdcd90c4ece005@mail.gmail.com>
	 <20070917.095919.48528018.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from py-out-1112.google.com ([64.233.166.177]:26563 "EHLO
	py-out-1112.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754688AbXIRHqQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Sep 2007 03:46:16 -0400
Received: by py-out-1112.google.com with SMTP id u77so3609681pyb
        for <netdev@vger.kernel.org>; Tue, 18 Sep 2007 00:46:15 -0700 (PDT)
In-Reply-To: <20070917.095919.48528018.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

Now it seems to me ok and I hope it can be applied cleanly. The only
change here is  "Copy neighbour" instead "Copy neighbout"  in the
comment in net/ipv4/xfrm4_policy.c

Regards,
Ian Brown

Signed-off-by: ianbrn@gmail.com


--- a/net/ipv4/xfrm4_policy.c	2007-09-01 09:08:24.000000000 +0300
+++ b/net/ipv4/xfrm4_policy.c	2007-09-17 09:36:04.000000000 +0200
@@ -166,7 +166,7 @@
 		dst_prev->trailer_len	= trailer_len;
 		memcpy(&dst_prev->metrics, &x->route->metrics, sizeof(dst_prev->metrics));

-		/* Copy neighbout for reachability confirmation */
+		/* Copy neighbour for reachability confirmation */
 		dst_prev->neighbour	= neigh_clone(rt->u.dst.neighbour);
 		dst_prev->input		= rt->u.dst.input;
 		/* XXX: When IPv6 module can be unloaded, we should manage reference



On 9/17/07, David Miller <davem@davemloft.net> wrote:
> From: "Ian Brown" <ianbrn@gmail.com>
> Date: Mon, 17 Sep 2007 09:50:15 +0200
>
> > Hello,
> >   This is a  trivial typo correction in net/ipv4/xfrm4_policy.c which
> > hunted my eye...
> >
> > Regards,
> > Ian Brown
> >
> > Signed-off-by: ianbrn@gmail.com
>
> Your mail client word-wrapped the patch so it doesn't apply
> cleanly, please report with full changelog et al. after
> you've corrected this.
>
> Thanks.
>
