From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: s6gmac: remove driver
Date: Tue, 11 Nov 2014 11:30:07 -0500 (EST)
Message-ID: <20141111.113007.194586174190893576.davem@davemloft.net>
References: <CAMo8BfJ-wvDoDmm+HLHvC3VRUshdqU4eJchOGYt_YJsUktap8Q@mail.gmail.com>
	<20141019.132801.424495087167944921.davem@davemloft.net>
	<1415694742.16021.11.camel@x220>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: valentinrothberg@gmail.com, jcmvbkbc@gmail.com, dg@emlix.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: pebolle@tiscali.nl
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1415694742.16021.11.camel@x220>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

=46rom: Paul Bolle <pebolle@tiscali.nl>
Date: Tue, 11 Nov 2014 09:32:22 +0100

> On Sun, 2014-10-19 at 13:28 -0400, David Miller wrote:
>> From: Max Filippov <jcmvbkbc@gmail.com>
>> Date: Sun, 19 Oct 2014 21:26:05 +0400
>>=20
>> > On Sun, Oct 19, 2014 at 8:45 PM, David Miller <davem@davemloft.net=
> wrote:
>> >> From: Daniel Gl=F6ckner <dg@emlix.com>
>> >> Date: Sun, 19 Oct 2014 00:49:05 +0200
>> >>
>> >>> The s6000 Xtensa support is removed from the kernel. There are n=
o
>> >>> other chips using this driver.
>> >>
>> >> That's not what I see in Linus's current tree:
>> >=20
>> > David, s6000 removal is queued for 3.18.
>>=20
>> Then there is zero reason for me to apply this to my networking
>> tree.
>=20
> Commit 4006e565e150 ("xtensa: remove s6000 variant and s6105 platform=
")
> is included in linux-next as of next-20141111. So now we see:
>     $ git grep XTENSA_VARIANT_S6000 next-20141111
>     next-20141111:drivers/net/ethernet/Kconfig:     depends on XTENSA=
_VARIANT_S6000
>=20
> Should Daniel resubmit, for net-next, perhaps with a commit explanati=
on
> that references this commit?

When the s6000 removal shows up in Linus's tree, submit it.
