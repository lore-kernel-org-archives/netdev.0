From: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <maze@google.com>
Subject: Re: [PATCH net-next] ipv6: RTAX_FEATURE_ALLFRAG causes inefficient
 TCP segment sizing
Date: Tue, 24 Apr 2012 14:51:55 -0700
Message-ID: <CANP3RGfioDcK0_v1k8x6cX6QgmBCRDTx8x+e7PDxdqqk249aHQ@mail.gmail.com>
References: <1335289058.5205.165.camel@edumazet-glaptop>
	<CANP3RGd0mV8RcH1zCLBg+N9sgPGbiynhOSfoUAYpcMgYsvzeNA@mail.gmail.com>
	<1335298228.5205.168.camel@edumazet-glaptop>
	<CANP3RGfhc+4FjB152r58AP66oZQmj0oY-Zh=9qNn9OABCXPwbw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Tore Anderson <tore@fud.no>, David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Tom Herbert <therbert@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:58222 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757862Ab2DXVv4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Apr 2012 17:51:56 -0400
Received: by iadi9 with SMTP id i9so1535658iad.19
        for <netdev@vger.kernel.org>; Tue, 24 Apr 2012 14:51:55 -0700 (PDT)
In-Reply-To: <CANP3RGfhc+4FjB152r58AP66oZQmj0oY-Zh=9qNn9OABCXPwbw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> I just don't see what not decreasing mtu below 1280 buys us.

In particular it seems like it would be a good idea to drop tcp mss...
