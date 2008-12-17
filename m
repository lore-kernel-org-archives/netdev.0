From: =?iso-8859-1?q?R=E9mi_Denis-Courmont?= <rdenis@simphalempin.com>
Subject: Re: [PATCH] IPv4 raw_hdrincl_nomangle sysctl
Date: Thu, 18 Dec 2008 00:21:00 +0200
Message-ID: <200812180021.00962@auguste.remlab.net>
References: <494964CA.5050109@gmail.com> <20081217.124841.169000877.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: katterjohn@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yop.chewa.net ([91.121.105.214]:34474 "EHLO yop.chewa.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751968AbYLQWVG convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Dec 2008 17:21:06 -0500
In-Reply-To: <20081217.124841.169000877.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 17 d=E9cembre 2008, David Miller a =E9crit :
> If you want full control, use AF_PACKET to send your frames.
>
> Yes, this means you'll need to choose the outgoing device and compose
> the link level header, but that's the price for control.

Does SOCK_DGRAM not save userland from crafting the LL header - contrar=
y=20
to SOCK_RAW?

--=20
R=E9mi Denis-Courmont
http://www.remlab.net/
