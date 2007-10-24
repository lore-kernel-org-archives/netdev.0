From: Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>
Subject: Re: [PATCH RESEND] ip_gre: sendto/recvfrom NBMA address
Date: Wed, 24 Oct 2007 14:08:42 +0400
Message-ID: <20071024100842.GA19369@ms2.inr.ac.ru>
References: <471E05BD.7040407@iki.fi> <471E0638.9040405@trash.net> <471E19E5.5040509@iki.fi> <20071023202036.GA12066@ms2.inr.ac.ru> <471EDE22.4090408@iki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>, davem@davemloft.net,
	netdev@vger.kernel.org
To: Timo Ter?s <timo.teras@iki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from minus.inr.ac.ru ([194.67.69.97]:54285 "HELO ms2.inr.ac.ru"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with SMTP
	id S1752227AbXJXKIx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 24 Oct 2007 06:08:53 -0400
Content-Disposition: inline
In-Reply-To: <471EDE22.4090408@iki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello!

> I was able to set a nbma gre tunnel, add routes to it and it worked
> perfectly ok.
> 
> Link-level next hop worked:
> ip route add <route> via <link-level-address> dev <tunnel-dev> onlink

This can work if you use gre0. By plain luck it has all-zero dev_addr.

It will break on nbma devices set with:

ip tunnel add XXX mode gre local a.b.c.d [key whatever] ...

Alexey
