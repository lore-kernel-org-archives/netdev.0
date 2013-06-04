From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Bad shaping at low rates, after commit 56b765b79 (htb: improved
 accuracy at high rates)
Date: Tue, 04 Jun 2013 08:18:53 -0700
Message-ID: <1370359133.24311.208.camel@edumazet-glaptop>
References: <20130529151330.22c5c89e@redhat.com>
	 <20130604141342.00c8eb9f@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Stephen Hemminger <stephen@networkplumber.org>,
	Jiri Benc <jbenc@redhat.com>, David Miller <davem@redhat.com>,
	j.vimal@gmail.com, Michal Soltys <soltys@ziu.info>,
	Mike Frysinger <vapier@gentoo.org>,
	Jussi Kivilinna <jussi.kivilinna@mbnet.fi>,
	Patrick McHardy <kaber@trash.net>,
	Jiri Pirko <jpirko@redhat.com>,
	Toke =?ISO-8859-1?Q?H=F8iland-J=F8rgensen?= <toke@toke.dk>,
	Dave Taht <dave.taht@gmail.com>, netdev@vger.kernel.org,
	bloat@lists.bufferbloat.net, Dan Siemon <dan@coverfire.com>,
	Jim Gettys <jg@freedesktop.org>,
	Steven Barth <cyrus@openwrt.org>, Felix Fietkau <nbd@nbd.name>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f45.google.com ([209.85.160.45]:41503 "EHLO
	mail-pb0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751802Ab3FDPS5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Jun 2013 11:18:57 -0400
Received: by mail-pb0-f45.google.com with SMTP id mc8so392566pbc.4
        for <netdev@vger.kernel.org>; Tue, 04 Jun 2013 08:18:56 -0700 (PDT)
In-Reply-To: <20130604141342.00c8eb9f@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-06-04 at 14:13 +0200, Jesper Dangaard Brouer wrote:
> Hi again,
> 
> I found another regression by commit 56b765b79 (htb: improved accuracy
> at high rates).
> 
> After the commit HTB does not honor network rate limiting below 500kbps.
> 
> I have found that the bandwidth problem is related to GSO being enabled
> on the device.  To test the situation, I had to use a real NIC (as I
> were not allowed to disable GSO on dev "lo", test below).

Well, do not forget lo mtu is 64K, so you'll also have to lower it for
your tests.

I have a good idea of what's going on for htb at low rates, I am testing
a fix, thanks for the report !
