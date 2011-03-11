From: "J. Bruce Fields" <bfields@fieldses.org>
Subject: Re: [GIT] Networking
Date: Fri, 11 Mar 2011 15:48:23 -0500
Message-ID: <20110311204823.GB7906@fieldses.org>
References: <20110310.153444.115930379.davem@davemloft.net>
 <AANLkTimnHtVS=SFopgyjAAQDW8bXDKDXf+YvEtPdpPsA@mail.gmail.com>
 <20110310.155556.48513201.davem@davemloft.net>
 <AANLkTik3AyFTNoytebmOOZ=JSFMkt0bw7au-CSncUHJu@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from fieldses.org ([174.143.236.118]:44099 "EHLO fieldses.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754172Ab1CKUs0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 11 Mar 2011 15:48:26 -0500
Content-Disposition: inline
In-Reply-To: <AANLkTik3AyFTNoytebmOOZ=JSFMkt0bw7au-CSncUHJu@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 10, 2011 at 04:29:30PM -0800, Linus Torvalds wrote:
> On Thu, Mar 10, 2011 at 3:55 PM, David Miller <davem@davemloft.net> w=
rote:
> > I should have put:
> >
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0Merge to get commit 8909c9ad8ff03611c9c9=
6c9a92656213e4bb495b
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0("net: don't allow CAP_NET_ADMIN to load=
 non-netdev kernel modules")
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0so that we can add Stephen Hemminger's f=
ix to handle ip6 tunnels
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0as well, which uses the MODULE_ALIAS_NET=
DEV() macro created by
> > =C2=A0 =C2=A0 =C2=A0 =C2=A0that change.
>=20
> Yeah, that would have explained it. That said, if you are merging for
> something like that, may I suggest actually starting off with
>=20
>    git merge 8909c9ad8ff03611c9c96c9a92656213e4bb495b
>=20
> that then actually makes the history itself also show the relationshi=
p
> (you'd still have to write the commit message explaining why,

By the way, I occasionally wonder whether it would make sense to make a
habit of committing bugfixes on top of the commit that introduced the
bug (at least in cases where there *is* a single commit that introduced
the bug).

As with the above, it'd make the history a little more self-documenting=
=2E
It might simplify life for backporters.  (In theory, they could do
merges instead of a cherry-picks if they wanted to.)  The set of "bad"
commits would be described by "fix^...fix".

But then I had some mental image if your saying "WTF?" the first time I
send you a post-rc1 pull request that looks like an octopus merge of a
dozen little 1- or 2- commit branches based all over the place.

I dunno, would it be annoying?

--b.
