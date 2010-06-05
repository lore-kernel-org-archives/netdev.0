From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] act_cpu: redirect skb receiving to a special CPU.
Date: Sat, 05 Jun 2010 17:00:15 +0200
Message-ID: <1275750015.5238.249.camel@edumazet-laptop>
References: <AANLkTikskTWJrULj2IKYhebxh9O_XTOMBy3i0wPY8thq@mail.gmail.com>
	 <1275743224.3490.44.camel@bigi>
	 <AANLkTiltF2APEnqHyHTtHA7JMNp3HX3aCu9UL3nUJ5_u@mail.gmail.com>
	 <1275746045.3490.60.camel@bigi>
	 <AANLkTim83nfQDuLNmYAvk6RBqxot0t6cGq-lbic4-DSs@mail.gmail.com>
	 <1275748004.3490.86.camel@bigi>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Changli Gao <xiaosuo@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Tom Herbert <therbert@google.com>,
	Linux Netdev List <netdev@vger.kernel.org>
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:60430 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933319Ab0FEPAU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Jun 2010 11:00:20 -0400
Received: by wyi11 with SMTP id 11so1489933wyi.19
        for <netdev@vger.kernel.org>; Sat, 05 Jun 2010 08:00:19 -0700 (PDT)
In-Reply-To: <1275748004.3490.86.camel@bigi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le samedi 05 juin 2010 =C3=A0 10:26 -0400, jamal a =C3=A9crit :

> Indeed it is AMD specific - but my view is if i was using AMD that wo=
uld
> be more efficient way of doing it; i.e IPI is the lowest common
> denominator which works on all archs. Essentially what i am saying is
> this would be a "inter-cpu messaging netdev" and i could replace its
> send/recv parts from what we do in the RPS path right now to one that
> uses AMD hypertransport etc.

You do realize this should be discussed on lkml , of course ?



