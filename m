From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: reduce the lines of code
Date: Fri, 19 Nov 2010 08:51:51 +0100
Message-ID: <1290153111.29509.2.camel@edumazet-laptop>
References: <1290132284-12328-1-git-send-email-xiaosuo@gmail.com>
	 <b2c34db84e88366e465af590900ae3db@localhost>
	 <AANLkTinccn2Biwh7d6d4kZJrJTgGbLjKApi2+dwGnvVL@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Hagen Paul Pfeifer <hagen@jauu.net>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:40292 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751293Ab0KSHv7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 19 Nov 2010 02:51:59 -0500
Received: by wyb28 with SMTP id 28so4151394wyb.19
        for <netdev@vger.kernel.org>; Thu, 18 Nov 2010 23:51:58 -0800 (PST)
In-Reply-To: <AANLkTinccn2Biwh7d6d4kZJrJTgGbLjKApi2+dwGnvVL@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 19 novembre 2010 =C3=A0 15:17 +0800, Changli Gao a =C3=A9cr=
it :=20
> On Fri, Nov 19, 2010 at 2:35 PM, Hagen Paul Pfeifer <hagen@jauu.net> =
wrote:
> >
> > On Fri, 19 Nov 2010 10:04:44 +0800, Changli Gao <xiaosuo@gmail.com>=
 wrote:
> >> Use macros to reduce the regularity lines.
> >
> > This is complete awkward and does not fix anything - on the contrar=
y it
> > makes it harder to understand the code and no advantage is achieved=
=2E
> >
>=20
> Although it doesn't fix anything, It can simplify the adding of new
> BPF instructions, one place in filter_def.h instead of two in
> filter.c. I think if some code can be generated automatically, we'd
> better not write it manually, as the chance of error is less when the
> code is generated automatically.
>=20

Idea is good, but the way you did it is not.

I have two patches in testing. I'll post them today.

One to remove all the "+ 1" we do in codes[] init

One at check time to replace the divide by a constant instruction
(DIV_K) by a reciprocal one (a multiply at exec time)



