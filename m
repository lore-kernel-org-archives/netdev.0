From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] iputils: ping by mark
Date: Sun, 18 Oct 2009 07:37:46 -0400
Message-ID: <1255865866.4815.21.camel@dogo.mojatatu.com>
References: <1255381558.5406.33.camel@dogo.mojatatu.com>
	 <7e84ed60910161405i2ce46053m9858b7f1c086e6b7@mail.gmail.com>
	 <1255782635.11213.7.camel@dogo.mojatatu.com>
	 <55a4f86e0910171154v460146a8m1360fac71f9ddac8@mail.gmail.com>
	 <1255820692.4815.2.camel@dogo.mojatatu.com>
	 <1255822485.4815.15.camel@dogo.mojatatu.com>
	 <55a4f86e0910171846w45dda0e9w86f570b087c1543d@mail.gmail.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Rob.Townley@gmail.com, YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>,
	netdev@vger.kernel.org
To: Maciej =?UTF-8?Q?=C5=BBenczykowski?= <zenczykowski@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f202.google.com ([209.85.221.202]:51048 "EHLO
	mail-qy0-f202.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753441AbZJRLku (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Oct 2009 07:40:50 -0400
Received: by qyk40 with SMTP id 40so2602026qyk.22
        for <netdev@vger.kernel.org>; Sun, 18 Oct 2009 04:40:54 -0700 (PDT)
In-Reply-To: <55a4f86e0910171846w45dda0e9w86f570b087c1543d@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On Sat, 2009-10-17 at 18:46 -0700, Maciej =C5=BBenczykowski wrote:
> Try it with a udp packet or a tcp connection - so_mark and ip rule
> fwmark only work for raw sockets (and maybe some other special cases)=
,
> unless you're lucky and the ip(6)tables mangle module just happens to
> rerun the routing decision (because it mangles the packet in some
> other way...).

It works fine with tcp and udp and to emphasize: i have never seen it
broken.
Above you mention iptables - I dont use it and that maybe the missing
part in our discussion.
I should note though that rpf is broken with policy routing;-> Now that
you got me going on this, I will post a patch.=20

cheers,
jamal

