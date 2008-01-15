From: Stephen Hemminger <stephen.hemminger@vyatta.com>
Subject: Re: [RFC 6/6] fib_trie: combine leaf and info
Date: Tue, 15 Jan 2008 08:19:05 -0800
Message-ID: <20080115081905.3b8b6f05@deepthought>
References: <20080112064646.282104074@linux-foundation.org>
	<20080112.205520.55747078.davem@davemloft.net>
	<4789A29C.6080000@linux-foundation.org>
	<20080112.214417.154179770.davem@davemloft.net>
	<20080114125755.6157a3bf@deepthought>
	<20080114164450.55f8c9b2@deepthought>
	<20080114164621.2bc5011f@deepthought>
	<20080114164727.210047f6@deepthought>
	<20080114185843.0981f0ff@deepthought>
	<20080114210716.4b09c84d@deepthought>
	<478C4EB7.6060807@cosmosbay.com>
	<478C4FBE.5040308@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, robert.olsson@its.uu.se,
	netdev@vger.kernel.org
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:54518 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751001AbYAOQVt convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jan 2008 11:21:49 -0500
In-Reply-To: <478C4FBE.5040308@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 15 Jan 2008 07:16:30 +0100
Eric Dumazet <dada1@cosmosbay.com> wrote:

> Eric Dumazet a =C3=A9crit :
> > Stephen Hemminger a =C3=A9crit :
> >> Combine the prefix information and the leaf together into one
> >> allocation. This is furthur simplified by converting the hlist
> >> into a simple bitfield.
> >>
> >> Signed-off-by: Stephen Hemminger <stephen.hemminger@vyatta.com>
> >>
> >> This patch is experimental (ie it boots and loads routes), but
> >> is slower for the 163,000 route dump test.
> >>
> >=20
> > Its also very memory expensive. That was not Robert suggestion I be=
lieve.
> >=20
> > Its suggestion is to embedd one info into each leaves.
> >=20
> > Please find attached to this mail a preliminary and incomplete patc=
h I=20
> > wrote this morning before coffee :), to get the idea.
>=20
> Oops, patch reversed, sorry, and against another work pending in my t=
ree.
>=20
> Now time for cofee :)
>=20

Okay, I would rather see the leaf_info explicit inside the leaf, also
your scheme probably breaks if I add two prefixes and then delete the f=
irst.
Let me have a go at it.

--=20
Stephen Hemminger <stephen.hemminger@vyatta.com>
