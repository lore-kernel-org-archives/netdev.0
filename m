From: James Chapman <jchapman@katalix.com>
Subject: Re: [PATCH 0/2] L2TP fixes
Date: Wed, 05 Mar 2014 07:23:49 +0000
Message-ID: <5316D105.5030407@katalix.com>
References: <cover.1393966618.git.g.nault@alphalink.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>
To: Guillaume Nault <g.nault@alphalink.fr>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from katalix.com ([82.103.140.233]:49303 "EHLO bert.katalix.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751441AbaCEHbx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Mar 2014 02:31:53 -0500
In-Reply-To: <cover.1393966618.git.g.nault@alphalink.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/03/14 21:24, Guillaume Nault wrote:
> Here's a small series, to fix some (probably not widely used) L2TPv2
> features:
>   -toggling L2TP sequencing option from userspace was broken because
>    of missing header length update,
>   -no data was ever returned to userspace when reading from L2TP
>    sockets, because pppol2tp_recv() did only handle the case of
>    L2TP sockets bound to a PPP channel.
> 
> Guillaume Nault (2):
>   l2tp: fix manual sequencing (de)activation in L2TPv2
>   l2tp: fix userspace reception on plain L2TP sockets
> 
>  net/l2tp/l2tp_core.c    |  5 +++--
>  net/l2tp/l2tp_core.h    |  1 +
>  net/l2tp/l2tp_netlink.c |  4 +++-
>  net/l2tp/l2tp_ppp.c     | 13 ++++++++-----
>  4 files changed, 15 insertions(+), 8 deletions(-)

Acked-by: James Chapman <jchapman@katalix.com>
