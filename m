From: David Miller <davem@davemloft.net>
Subject: Re: [34/44] Limit sysctl_tcp_mem and sysctl_udp_mem initializers
 to prevent integer overflows.
Date: Wed, 08 Dec 2010 08:25:22 -0800 (PST)
Message-ID: <20101208.082522.226789733.davem@davemloft.net>
References: <AANLkTimTw3O-OM-5Cgv0ELNj8SmMjaaeMHMd2NNezxi7@mail.gmail.com>
	<20101208041656.GA2291@suse.de>
	<1291787445.5324.64.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: gregkh@suse.de, torvalds@linux-foundation.org,
	linux-kernel@vger.kernel.org, stable@kernel.org,
	stable-review@kernel.org, akpm@linux-foundation.org,
	alan@lxorguk.ukuu.org.uk, holt@sgi.com, w@1wt.eu,
	netdev@vger.kernel.org, linux-sctp@vger.kernel.org,
	kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net,
	vladislav.yasevich@hp.com, sri@us.ibm.com
To: eric.dumazet@gmail.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1291787445.5324.64.camel@edumazet-laptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 08 Dec 2010 06:50:45 +0100

> Le mardi 07 d=E9cembre 2010 =E0 20:16 -0800, Greg KH a =E9crit :
>> On Tue, Dec 07, 2010 at 05:22:34PM -0800, Linus Torvalds wrote:
>> > On Tue, Dec 7, 2010 at 4:04 PM, Greg KH <gregkh@suse.de> wrote:
>> > >
>> > > From: Robin Holt <holt@sgi.com>
>> > >
>> > > [ Problem was fixed differently upstream. -DaveM ]
>> >=20
>> > Gaah. I'd really like to see more of a description for things like
>> > this. A commit ID for the alternate fix, or at least a few words a=
bout
>> > the different fix or reason why upstream doesn't need the stable
>> > commit.
>>=20
>> I'll let David confirm this, he's the one who sent it to me :)
>=20
> upstream uses commit 8d987e5c7510 (net: avoid limits overflow)
>=20
> This commit is a bit more untrusive for stable kernels :
>=20
> It depends on :
> a9febbb4bd13 (sysctl: min/max bounds are optional)
> 27b3d80a7b6a (sysctl: fix min/max handling in __do_proc_doulongvec_mi=
nmax())

Yep, this is the case.  Greg, you can add a reference to:

a9febbb4bd13
27b3d80a7b6a
8d987e5c7510

in my "[ ... ]" in the commit message to clear this up.
