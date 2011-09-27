From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ipv6-multicast: Fix memory leak in input path.
Date: Tue, 27 Sep 2011 22:08:46 +0200
Message-ID: <1317154126.2472.2.camel@edumazet-laptop>
References: <1317149897-14932-1-git-send-email-greearb@candelatech.com>
	 <20110927.151616.1706187903528893128.davem@davemloft.net>
	 <4E822552.7000401@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:47421 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752061Ab1I0UIw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Sep 2011 16:08:52 -0400
Received: by bkbzt4 with SMTP id zt4so7318308bkb.19
        for <netdev@vger.kernel.org>; Tue, 27 Sep 2011 13:08:51 -0700 (PDT)
In-Reply-To: <4E822552.7000401@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 27 septembre 2011 =C3=A0 12:34 -0700, Ben Greear a =C3=A9crit =
:
> On 09/27/2011 12:16 PM, David Miller wrote:
> > From: greearb@candelatech.com
> > Date: Tue, 27 Sep 2011 11:58:17 -0700
> >
> >> From: Ben Greear<greearb@candelatech.com>
> >>
> >> Have to free the skb before returning if we fail
> >> the fib lookup.
> >>
> >> Signed-off-by: Ben Greear<greearb@candelatech.com>
> >
> > Applied, thanks.
>=20
> Thanks.
>=20
> This bug was introduced in 2.6.35, I believe, so should probably send
> this to stable as well.
>=20

A good way to handle this is to include in the changelog of the patch
the reference on faulty commit, to ease David and stable teams work.

Commit d1db275dd3f6
(ipv6: ip6mr: support multiple tables)
