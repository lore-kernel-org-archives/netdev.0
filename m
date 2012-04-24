From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] tcp: introduce tcp_try_coalesce
Date: Tue, 24 Apr 2012 04:29:29 +0200
Message-ID: <1335234569.5205.100.camel@edumazet-glaptop>
References: <1335201102.5205.28.camel@edumazet-glaptop>
	 <CADVnQyngwym7z_zSi8h2U_1e_wVCwGMPZScywWFWM2AYvxyqjw@mail.gmail.com>
	 <1335233611.5205.90.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Tom Herbert <therbert@google.com>,
	Maciej =?UTF-8?Q?=C5=BBenczykowski?= <maze@google.com>,
	Ilpo =?ISO-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
To: Neal Cardwell <ncardwell@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f170.google.com ([209.85.212.170]:39202 "EHLO
	mail-wi0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756165Ab2DXC3f (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Apr 2012 22:29:35 -0400
Received: by wibhr17 with SMTP id hr17so3066694wib.1
        for <netdev@vger.kernel.org>; Mon, 23 Apr 2012 19:29:34 -0700 (PDT)
In-Reply-To: <1335233611.5205.90.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-04-24 at 04:13 +0200, Eric Dumazet wrote:

> This never happens on connections where performance matters : skb head
> can only contains one full mss segment.

By the way, top end hardware uses fragged skbs.

Incidentally this gives better splice() performance (avoids copy of skb
head to pages)
