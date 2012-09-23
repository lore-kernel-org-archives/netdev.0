From: Jan Engelhardt <jengelh@inai.de>
Subject: Re: loop back address question
Date: Sun, 23 Sep 2012 14:37:39 +0200 (CEST)
Message-ID: <alpine.LNX.2.01.1209231433560.9625@nerf07.vanv.qr>
References: <CAGZFCEE=Txa4=meB7CTuWvcgFe4teiXG3LWbOua21TqXXYY1SQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: ratheesh kannoth <ratheesh.ksz@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ares07.inai.de ([5.9.24.206]:46276 "EHLO seven.medozas.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752528Ab2IWMhm (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 23 Sep 2012 08:37:42 -0400
In-Reply-To: <CAGZFCEE=Txa4=meB7CTuWvcgFe4teiXG3LWbOua21TqXXYY1SQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tuesday 2012-09-18 15:42, ratheesh kannoth wrote:

>Hi ,
>
>i have two  linux machines(2.6.29 ) A & B, both  connected  to same lan network
>
>1)  if  i assign 127.0.2.1 and 127.0.2.2 to interfaces , can we ping
>each other ?  is there any way to  send packets out of interface ?

1. The route "local 127.0.0.0/8 dev lo" in the local table has a higher 
priority than the main table, so you would need to reorder that first.

2. There are a handful of places in linux where ipv4_is_loopback() is 
used on addresses to take a different path, so the chances to 
successfully get 127.0.2.0/24 packets out an interface may not be 100%.

Just in case you tried selling blocks out of your 127 block to someone..
