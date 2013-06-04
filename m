From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net_sched: htb: do not mix 1ns and 64ns time units
Date: Tue, 04 Jun 2013 14:02:13 -0700
Message-ID: <1370379733.24311.229.camel@edumazet-glaptop>
References: <20130529151330.22c5c89e@redhat.com>
	 <20130604141342.00c8eb9f@redhat.com>
	 <1370359133.24311.208.camel@edumazet-glaptop>
	 <1370361306.24311.214.camel@edumazet-glaptop>
	 <1370361727.24311.215.camel@edumazet-glaptop>
	 <1370365908.24311.222.camel@edumazet-glaptop>
	 <20130604222135.67eedab8@redhat.com>
	 <CAA93jw6BQ_Ji5zHxR93PPxAmAWg8VmRSYBFKTpJDFWE4MApaRg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jesper Dangaard Brouer <jbrouer@redhat.com>,
	netdev@vger.kernel.org, Jesper Dangaard Brouer <brouer@redhat.com>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Jiri Benc <jbenc@redhat.com>, David Miller <davem@redhat.com>,
	j.vimal@gmail.com, Michal Soltys <soltys@ziu.info>,
	Mike Frysinger <vapier@gentoo.org>,
	Jussi Kivilinna <jussi.kivilinna@mbnet.fi>,
	Patrick McHardy <kaber@trash.net>,
	Jiri Pirko <jpirko@redhat.com>,
	Toke =?ISO-8859-1?Q?H=F8iland-J=F8rgensen?= <toke@toke.dk>,
	bloat@lists.bufferbloat.net, Dan Siemon <dan@coverfire.com>,
	Jim Gettys <jg@freedesktop.org>,
	Steven Barth <cyrus@openwrt.org>, Felix Fietkau <nbd@nbd.name>
To: Dave Taht <dave.taht@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f45.google.com ([209.85.160.45]:52981 "EHLO
	mail-pb0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751458Ab3FDVCP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Jun 2013 17:02:15 -0400
Received: by mail-pb0-f45.google.com with SMTP id mc8so783177pbc.18
        for <netdev@vger.kernel.org>; Tue, 04 Jun 2013 14:02:15 -0700 (PDT)
In-Reply-To: <CAA93jw6BQ_Ji5zHxR93PPxAmAWg8VmRSYBFKTpJDFWE4MApaRg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-06-04 at 13:26 -0700, Dave Taht wrote:
> 

> 
> I'm not worried about it but will find out shortly in cerowrt.
> 
> I take it this does not fix the DSL/ATM issue however?
>  
> 
Really, the DSL/ATM stuff should use the STAB thing. 

I suppose you already disabled GSO/TSO anyway.

__qdisc_calculate_pkt_len() contains all we need, for this kind of
situation.
