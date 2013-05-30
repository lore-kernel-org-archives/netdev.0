From: "Steinar H. Gunderson" <sgunderson@bigfoot.com>
Subject: Re: [Bloat] tc linklayer ADSL calc broken after commit 56b765b79
 (htb: improved accuracy at high rates)
Date: Thu, 30 May 2013 11:52:53 +0200
Message-ID: <20130530095253.GA8461@uio.no>
References: <20130529151330.22c5c89e@redhat.com>
 <1369842724.5109.44.camel@edumazet-glaptop>
 <20130529155034.334092c5@nehalam.linuxnetplumber.net>
 <1369869506.5109.87.camel@edumazet-glaptop>
 <20130530111547.07397287@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Toke =?utf-8?Q?H=C3=B8iland-J=C3=B8rgensen?= <toke@toke.dk>,
	Mike Frysinger <vapier@gentoo.org>,
	Jiri Benc <jbenc@redhat.com>, Jiri Pirko <jpirko@redhat.com>,
	netdev@vger.kernel.org, bloat@lists.bufferbloat.net,
	Patrick McHardy <kaber@trash.net>,
	Steven Barth <cyrus@openwrt.org>,
	"russell-tcatm@stuart.id.au" <russell-tcatm@stuart.id.au>,
	David Miller <davem@redhat.com>,
	Jussi Kivilinna <jussi.kivilinna@mbnet.fi>,
	Felix Fietkau <nbd@nbd.name>, Michal Soltys <soltys@ziu.info>
To: Jesper Dangaard Brouer <jbrouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cassarossa.samfundet.no ([193.35.52.29]:36279 "EHLO
	cassarossa.samfundet.no" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030270Ab3E3JxE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 May 2013 05:53:04 -0400
Content-Disposition: inline
In-Reply-To: <20130530111547.07397287@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 30, 2013 at 11:15:47AM +0200, Jesper Dangaard Brouer wrote:
>  int pkt_len = skb->len + (encap_overhead * gso_segments);
>  int wire_sz = DIV_ROUND_UP(pkt_len,48)*53;
> 
> (I suspect, that the compiler might even optimize and remove any
> real divisions, I bet Eric can tell us.)

FWIW, GCC can change divisions by integer constants (even signed divisions)
to some multiplies and shifts, by way of some number theory magic.

/* Steinar */
-- 
Homepage: http://www.sesse.net/
