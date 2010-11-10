From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 0/2] net: Changes in queue allocation and freeing
Date: Wed, 10 Nov 2010 11:41:36 +0100
Message-ID: <1289385696.2860.147.camel@edumazet-laptop>
References: <alpine.DEB.1.00.1011091240470.18565@pokey.mtv.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:46339 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752747Ab0KJKll (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Nov 2010 05:41:41 -0500
Received: by wwb39 with SMTP id 39so567144wwb.1
        for <netdev@vger.kernel.org>; Wed, 10 Nov 2010 02:41:39 -0800 (PST)
In-Reply-To: <alpine.DEB.1.00.1011091240470.18565@pokey.mtv.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 09 novembre 2010 =C3=A0 12:47 -0800, Tom Herbert a =C3=A9crit =
:
> Changes to both RX and TX queue allocation.  In both cases allocate
> in alloc_netdev_mq and free in free_netdev.  For RX the reference
> couting also changed, the device reference count can now be used.

Oh well :)

Are they preliminary patches so that XPS also dont need the "reference
counts specific to TX queues" ? ;)



