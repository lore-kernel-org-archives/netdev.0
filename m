From: Arnaud Lacombe <lacombar@gmail.com>
Subject: Re: linux-next: boot test failure (net tree)
Date: Mon, 22 Aug 2011 23:50:02 -0400
Message-ID: <CACqU3MW4BnucRt3gxPrKPDvWEjaVuxRF1VOPWk5hTRfneyANkg@mail.gmail.com>
References: <20110822113032.15087c2e190e2b0c3ee7dfb8@canb.auug.org.au>
	<20110823114011.a059aea0138b75bfa7eed1ce@canb.auug.org.au>
	<20110823114129.ceb18da164bf7df3c145941b@canb.auug.org.au>
	<20110822.191348.2099822249437201579.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: sfr@canb.auug.org.au, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	jeffrey.t.kirsher@intel.com, mikey@neuling.org,
	torvalds@linux-foundation.org, akpm@linux-foundation.org,
	linuxppc-dev@lists.ozlabs.org, benh@kernel.crashing.org,
	paulus@samba.org, linux-kbuild@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kbuild-owner@vger.kernel.org>
In-Reply-To: <20110822.191348.2099822249437201579.davem@davemloft.net>
Sender: linux-kbuild-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

[Added linux-kbuild@ to the Cc: list.]

On Mon, Aug 22, 2011 at 10:13 PM, David Miller <davem@davemloft.net> wr=
ote:
> From: Stephen Rothwell <sfr@canb.auug.org.au>
> Date: Tue, 23 Aug 2011 11:41:29 +1000
>
>> On Tue, 23 Aug 2011 11:40:11 +1000 Stephen Rothwell <sfr@canb.auug.o=
rg.au> wrote:
>>>
>>> On Mon, 22 Aug 2011 11:30:32 +1000 Stephen Rothwell <sfr@canb.auug.=
org.au> wrote:
>>> >
>>> > Here's what I am applying as a merge fixup to the net tree today =
so that
>>> > my ppc64_defconfig builds actually build more or less the same se=
t of
>>> > drivers as before this rearrangement.
>>>
>>> And this today:
>>
>> And this:
>
> I'm starting to get uncomfortable with this whole situation, and I
> feel more and more that these new kconfig guards are not tenable.
>
> Changing defconfig files might fix the "automated test boot with
> defconfig" case but it won't fix the case of someone trying to
> automate a build and boot using a different, existing, config file.
> It ought to work too, and I do know people really do this.
>
> And just the fact that we would have to merge all of these defconfig =
changes
> through the networking tree is evidence of how it's really not reason=
able
> to be doing things this way.
>
> Jeff, I think we need to revert the dependencies back to what they we=
re
> before the drivers/net moves. =A0Could you prepare a patch which does=
 that?
>
Are you implying we need some kind of way to migrate config ?

 - Arnaud
--
To unsubscribe from this list: send the line "unsubscribe linux-kbuild"=
 in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
