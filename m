From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: WARNING: at net/ipv4/tcp.c:1610 tcp_recvmsg+0xb1b/0xc70()
Date: Mon, 28 May 2012 02:25:27 +0200
Message-ID: <1338164727.2240.14.camel@edumazet-glaptop>
References: <4FBFEACC.8040601@fastmail.fm>
	 <1337978725.10135.0.camel@edumazet-glaptop>
	 <1337979331.10135.2.camel@edumazet-glaptop> <4FC0BCE1.6070601@fastmail.fm>
	 <1338127184.3670.50.camel@edumazet-glaptop> <4FC24987.4090708@fastmail.fm>
	 <1338140156.3786.10.camel@edumazet-glaptop>  <4FC27CE7.20604@fastmail.fm>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org,
	Linux Kernel <linux-kernel@vger.kernel.org>
To: Jack Stone <jwjstone@fastmail.fm>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wg0-f44.google.com ([74.125.82.44]:64654 "EHLO
	mail-wg0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751191Ab2E1AZd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 27 May 2012 20:25:33 -0400
In-Reply-To: <4FC27CE7.20604@fastmail.fm>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2012-05-27 at 20:13 +0100, Jack Stone wrote:

> Could it be something to do with my staging network driver?

drivers/staging/rtl8712/rtl8712_recv.c

line 1096

precvframe->u.hdr.pkt = skb_clone(pskb, GFP_ATOMIC);

This looks very wrong.
Make sure you never _never_ hit this path.
