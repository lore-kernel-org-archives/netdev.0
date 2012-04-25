From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] ipv6: RTAX_FEATURE_ALLFRAG causes inefficient
 TCP segment sizing
Date: Wed, 25 Apr 2012 12:15:29 +0200
Message-ID: <1335348929.3274.33.camel@edumazet-glaptop>
References: <1335289058.5205.165.camel@edumazet-glaptop>
	 <CANP3RGd0mV8RcH1zCLBg+N9sgPGbiynhOSfoUAYpcMgYsvzeNA@mail.gmail.com>
	 <1335298228.5205.168.camel@edumazet-glaptop>
	 <CANP3RGfhc+4FjB152r58AP66oZQmj0oY-Zh=9qNn9OABCXPwbw@mail.gmail.com>
	 <1335331960.5205.180.camel@edumazet-glaptop>
	 <CANP3RGdhs8s_RytR=f8ismSZdGs91bpVq=ZAjb0EOm-gCsDPAw@mail.gmail.com>
	 <f88609a3e80bbe53233e62dec2699a3e@greed.fud.no>
	 <CANP3RGcGH6Su8Lvt34eTDF2iv2HSipo2DvybXGQA4pXZj_qb9Q@mail.gmail.com>
	 <4c435f101fb7c653fd3b4e81980250e7@greed.fud.no>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Maciej =?UTF-8?Q?=C5=BBenczykowski?= <maze@google.com>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Tom Herbert <therbert@google.com>
To: Tore Anderson <tore@fud.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:43020 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757133Ab2DYKPj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Apr 2012 06:15:39 -0400
Received: by bkuw12 with SMTP id w12so1226677bku.19
        for <netdev@vger.kernel.org>; Wed, 25 Apr 2012 03:15:37 -0700 (PDT)
In-Reply-To: <4c435f101fb7c653fd3b4e81980250e7@greed.fud.no>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-04-25 at 12:04 +0200, Tore Anderson wrote:

> 
> Also, I'm not really sure if the IPv4 minimum PMTU is defined as 576 or
> 68 bytes. There are some conflicting information out there, and nothing 
> really
> authoritative either way (that I've found at least).

576 certainly not.

68 seems to be allowed
