From: kuznet@ms2.inr.ac.ru
Subject: Re: [PATCH] Networking: send-to-self [link to non-broken patch this
Date: Fri, 27 Sep 2002 07:36:02 +0400 (MSD)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200209270336.HAA19631@sex.inr.ac.ru>
References: <3D93B4CB.8040905@candelatech.com>
Mime-Version: 1.0
Cc: netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: greearb@candelatech.com (Ben Greear)
In-Reply-To: <3D93B4CB.8040905@candelatech.com> from "Ben Greear" at Sep 26, 2 06:30:51 pm
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello!

> Think about this:  Suppose you are connecting to a listening socket that has been
> bound to a device.  That creates the the temporary socket structure
> on the receive side,

That does _not_. All transmits use listening socket structure.


> can get routed based on the parent's bound_dev_if if my assumption here is
> not correct.

Find function tcp_v4_send_synack(), then tcp_v4_route_req() and derive
that your modifications have exactly zero impact on it,
sk->bound_dev_if is setup and used exactly like it was used before.

Alexey
