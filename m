From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] pktgen: fix transmission headers with frags=0
Date: Mon, 14 Mar 2011 15:18:58 +0100
Message-ID: <1300112338.3423.27.camel@edumazet-laptop>
References: <4D7E167E.2090807@gmail.com>
	 <1300110977.3423.16.camel@edumazet-laptop>  <4D7E22A5.1000708@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Robert Olsson <robert@herjulf.net>,
	Jens Laas <jens.laas@its.uu.se>,
	Voravit Tanyingyong <voravit@kth.se>
To: Daniel Turull <daniel.turull@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:41228 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755432Ab1CNOTE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Mar 2011 10:19:04 -0400
Received: by bwz15 with SMTP id 15so4462082bwz.19
        for <netdev@vger.kernel.org>; Mon, 14 Mar 2011 07:19:02 -0700 (PDT)
In-Reply-To: <4D7E22A5.1000708@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 14 mars 2011 =C3=A0 15:13 +0100, Daniel Turull a =C3=A9crit :
> On 03/14/2011 02:56 PM, Eric Dumazet wrote:

> > Good catch !
> >=20
> > Hmm this patch is not correct, why memset(data + 1, ...) ?
>=20
> I kept the +1 as it was in the original code, but I supposed it can b=
e avoided.
>=20

original code was assuming pgh was at right location.

pgh + 1 : really pointed to first byte after pktgen header.


data + 1 : points one byte off (so we leak one byte of kernel memory,
security guys would complain a lot...)

> I think that the second is better and more compact.
>=20
> Do I resend the new patch?

Yes please ;)


