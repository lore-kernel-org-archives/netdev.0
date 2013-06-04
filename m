From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Bad shaping at low rates, after commit 56b765b79 (htb: improved
 accuracy at high rates)
Date: Tue, 04 Jun 2013 09:02:07 -0700
Message-ID: <1370361727.24311.215.camel@edumazet-glaptop>
References: <20130529151330.22c5c89e@redhat.com>
	 <20130604141342.00c8eb9f@redhat.com>
	 <1370359133.24311.208.camel@edumazet-glaptop>
	 <1370361306.24311.214.camel@edumazet-glaptop>
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
Received: from mail-pb0-f43.google.com ([209.85.160.43]:34890 "EHLO
	mail-pb0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755798Ab3FDQCK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Jun 2013 12:02:10 -0400
Received: by mail-pb0-f43.google.com with SMTP id ma3so445731pbc.30
        for <netdev@vger.kernel.org>; Tue, 04 Jun 2013 09:02:10 -0700 (PDT)
In-Reply-To: <1370361306.24311.214.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-06-04 at 08:55 -0700, Eric Dumazet wrote:
> On Tue, 2013-06-04 at 08:18 -0700, Eric Dumazet wrote:
> 
> > I have a good idea of what's going on for htb at low rates, I am testing
> > a fix, thanks for the report !
> > 
> 
> Yes, we need to convert whole thing to use ns units, instead
> of a mix of 64ns and 1ns units.
> 
> Please test the following patch :

Oh well, it works only on 64bit arches.

I'll send a more complete patch, but thats the idea
