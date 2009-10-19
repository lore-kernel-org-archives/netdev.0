From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH][RFC]: ingress socket filter by mark
Date: Mon, 19 Oct 2009 08:12:05 -0400
Message-ID: <1255954325.21059.3.camel@dogo.mojatatu.com>
References: <1255869758.4815.40.camel@dogo.mojatatu.com>
	 <4ADB5043.7070707@gmail.com> <1255897680.4815.63.camel@dogo.mojatatu.com>
	 <55a4f86e0910181609o6b21d667g8e65638667a1d687@mail.gmail.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Atis Elsts <atis@mikrotik.com>
To: Maciej =?UTF-8?Q?=C5=BBenczykowski?= <zenczykowski@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f179.google.com ([209.85.216.179]:48196 "EHLO
	mail-px0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753952AbZJSMPJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Oct 2009 08:15:09 -0400
Received: by pxi9 with SMTP id 9so1069933pxi.4
        for <netdev@vger.kernel.org>; Mon, 19 Oct 2009 05:15:14 -0700 (PDT)
In-Reply-To: <55a4f86e0910181609o6b21d667g8e65638667a1d687@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2009-10-18 at 16:09 -0700, Maciej =C5=BBenczykowski wrote:
>=20
> I agree that being able to filter on mark in bpf makes a lot of sense=
=2E

I agree as well - i posted a patch yesterday; i just tested it and it
works so i will formally post it shortly.

> I wonder if we're not hitting the filters potentially before the mark
> is set though (on receive at least)...
> I'm nowhere near sure but I think packets get diverted/cloned to
> tcpdump before they hit the ip stack (and thus potentially get marked
> by ip(6)table mangle rules)

There are many ways to mark the packets before they get to the socket.
tc ingress provides at least two ways (ipt action and recently posted
patch by me on skbedit); iptables as well.

cheers,
jamal

