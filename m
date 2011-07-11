From: Geert Uytterhoeven <geert@linux-m68k.org>
Subject: Re: [RFC 43/72] a2065/ariadne: Move the a2065/ariadne drivers
Date: Mon, 11 Jul 2011 08:33:23 +0200
Message-ID: <CAMuHMdXfpbbfv7oT+0oDWJd0=x0BBqEeCcGWaxMHagTXoeCscQ@mail.gmail.com>
References: <1309010363-22750-1-git-send-email-jeffrey.t.kirsher@intel.com>
	<1309010363-22750-44-git-send-email-jeffrey.t.kirsher@intel.com>
	<BANLkTin_SRhrd4dnfBH48b1aTikw5-mjtg@mail.gmail.com>
	<1310221836.26989.11.camel@jtkirshe-mobl>
	<CAMuHMdVHRNk4arc75QKrzDmHYE+86NixPk6v9uGwOAPkUTCgJw@mail.gmail.com>
	<1310345295.26989.76.camel@jtkirshe-mobl>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: jeffrey.t.kirsher@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:65106 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756588Ab1GKGdY convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jul 2011 02:33:24 -0400
Received: by iyb12 with SMTP id 12so3390325iyb.19
        for <netdev@vger.kernel.org>; Sun, 10 Jul 2011 23:33:23 -0700 (PDT)
In-Reply-To: <1310345295.26989.76.camel@jtkirshe-mobl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 11, 2011 at 02:48, Jeff Kirsher <jeffrey.t.kirsher@intel.co=
m> wrote:
> On Sun, 2011-07-10 at 12:34 -0700, Geert Uytterhoeven wrote:
>> On Sat, Jul 9, 2011 at 16:30, Jeff Kirsher
>> <jeffrey.t.kirsher@intel.com> wrote:
>> > On Tue, 2011-06-28 at 13:33 -0700, Geert Uytterhoeven wrote:
>> >> And (in some other patch) 82596.c is an Intel driver, not a
>> Motorola driver.
>> >
>> > 82596.c is not an Intel driver, it is an Intel part. =C2=A0The dri=
ver was
>>
>> Sorry, I meant "driver for an Intel part".
>>
>> > written and support by someone other than Intel. =C2=A0I am lookin=
g at
>> how to
>>
>> Sure. But I'm strongly against classifying drivers based on who wrot=
e
>> them ;-)
>
> I agree to some extent, because if that were the case, we would have =
a
> donald_becker/ directory for several of the drivers. :)
>
> Here is one of the problem's I keep running into and there is no simp=
le
> answer. =C2=A0While most of the drivers can be grouped together by th=
e
> hardware they use, that does not work "logically" for every driver.
>
> In addition, if vendor 'A' makes a part and vendor 'B' uses same part=
 in
> a device/system/NIC and vendor 'B' creates the driver, supports the
> driver and maintains the driver. =C2=A0Should the part be categorized=
 under
> vendor 'A'? =C2=A0IMHO, I think it should be categorized as a vendor =
'B'
> driver.

Several of the Ethernet drivers are of a third type: vendor A chip, ven=
dor B
card, entity C software.

> I started this work with the idea of trying to organize the drivers i=
n
> the same way that the drivers were to be in the Kconfig, which tended=
 to
> be drivers/net/ethernet/<manufacturer>.
>
> One of the problems that arise in this organization is what do we do
> when vendor A is bought by vendor B, and vendor B takes on the suppor=
t
> of all the old vendor A parts/drivers?

We don't care. We don't sort drivers by who support them. Eventually, v=
endors
lose interest and they all end up under "Linux kernel community" anyway=
=2E

> So I am open to suggestions. =C2=A0The process I have using to organi=
ze the
> drivers has been to group drivers that use common libraries and/or co=
de
> first, then group by either manufacturer, maintainer, or common
> platform.
>
> I would like to keep the lasi_82506.c, sni_82596.c, 82506.c and simil=
ar
> drivers out of the intel/ directory because we would not be supportin=
g
> the drivers and they are not similar to our drivers that we do suppor=
t
> that would be in the intel/ directory.
>
> Again, I open to suggestions on how to best organize these types of
> drivers. =C2=A0Maybe create a misc/ or <bus_type>/ for these types of
> drivers?

"Similar" drivers should be together and consolidated (if someone has t=
ime
to do it). They can even be of different brands.
I.e. not all Tulip-compatibles were manufactured by Digital or Intel.

>> > better organize the 82596.c, lasi_82596.c, lib82596.c, and
>> sni_82596.c
>> > which all use an Intel Ethernet chip but were written and supporte=
d
>> by
>> > someone other than Intel.

Gr{oetje,eeting}s,

=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 Geert

--
Geert Uytterhoeven -- There's lots of Linux beyond ia32 -- geert@linux-=
m68k.org

In personal conversations with technical people, I call myself a hacker=
=2E But
when I'm talking to journalists I just say "programmer" or something li=
ke that.
=C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0=C2=A0 =C2=A0=C2=A0 -- Linus Torvalds
