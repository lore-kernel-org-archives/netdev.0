From: David Miller <davem@davemloft.net>
Subject: Re: [GIT] Networking
Date: Thu, 10 Mar 2011 16:34:34 -0800 (PST)
Message-ID: <20110310.163434.260095615.davem@davemloft.net>
References: <AANLkTimnHtVS=SFopgyjAAQDW8bXDKDXf+YvEtPdpPsA@mail.gmail.com>
	<20110310.155556.48513201.davem@davemloft.net>
	<AANLkTik3AyFTNoytebmOOZ=JSFMkt0bw7au-CSncUHJu@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: torvalds@linux-foundation.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <AANLkTik3AyFTNoytebmOOZ=JSFMkt0bw7au-CSncUHJu@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Linus Torvalds <torvalds@linux-foundation.org>
Date: Thu, 10 Mar 2011 16:29:30 -0800

> On Thu, Mar 10, 2011 at 3:55 PM, David Miller <davem@davemloft.net> w=
rote:
>> I should have put:
>>
>> =A0 =A0 =A0 =A0Merge to get commit 8909c9ad8ff03611c9c96c9a92656213e=
4bb495b
>> =A0 =A0 =A0 =A0("net: don't allow CAP_NET_ADMIN to load non-netdev k=
ernel modules")
>> =A0 =A0 =A0 =A0so that we can add Stephen Hemminger's fix to handle =
ip6 tunnels
>> =A0 =A0 =A0 =A0as well, which uses the MODULE_ALIAS_NETDEV() macro c=
reated by
>> =A0 =A0 =A0 =A0that change.
>=20
> Yeah, that would have explained it. That said, if you are merging for
> something like that, may I suggest actually starting off with
>=20
>    git merge 8909c9ad8ff03611c9c96c9a92656213e4bb495b
>=20
> that then actually makes the history itself also show the relationshi=
p
> (you'd still have to write the commit message explaining why,
> otherwise git will try to be "helpful" by making the merge commit
> message be
>=20
>    Merge commit '8909c9ad8ff03611c9c96c9a92656213e4bb495b'
>=20
> which while _technically_ more useful and indicative of what you
> wanted to do isn't actually any more readable than the one you have
> now.
>=20
> But the reason it would have been better is that it would literally
> have made the git commit parenthood point to the commit you actually
> care about.

So, this is like a cherry-pick of sorts that doesn't create new commits=
?
It just makes the merge commit, and that's where I explain why I need t=
his
particular change in my tree.

Right?
