From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: 2.6.29 e100.c non-MII support status? (Re: [GIT]: Networking)
Date: Sun, 1 Mar 2009 02:57:46 -0800
Message-ID: <9929d2390903010257p7c6fb367ga974767605033bc9@mail.gmail.com>
References: <20081228.000118.121541932.davem@davemloft.net>
	 <20081229102515.GA17171@rhlx01.hs-esslingen.de>
	 <20081229091728.d869f1c1.akpm@linux-foundation.org>
	 <9929d2390812291515y623d6a51yed1bef021ab6847e@mail.gmail.com>
	 <20081230120756.GA5393@rhlx01.hs-esslingen.de>
	 <20090228203757.GA18850@rhlx01.hs-esslingen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andrew Morton <akpm@linux-foundation.org>,
	David Miller <davem@davemloft.net>,
	torvalds@linux-foundation.org, bunk@kernel.org,
	auke-jan.h.kok@intel.com, e1000-devel@lists.sourceforge.net,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: andi@lisas.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.241]:59945 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751767AbZCAK5s convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Mar 2009 05:57:48 -0500
In-Reply-To: <20090228203757.GA18850@rhlx01.hs-esslingen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Feb 28, 2009 at 12:37 PM, Andreas Mohr
<andim2@users.sourceforge.net> wrote:
> Hi,
>
> On Tue, Dec 30, 2008 at 01:07:56PM +0100, Andreas Mohr wrote:
>> On Mon, Dec 29, 2008 at 03:15:37PM -0800, Jeff Kirsher wrote:
>> > He is referring to a patch to add support for devices which do not=
 use
>> > the MII interface which use an Intel MAC. =C2=A0I have the patch i=
n my
>> > local tree and have been keeping it up-to-date. =C2=A0I should hav=
e an
>> > update on this patch after the New Year.
>>
>> Thanks!
>>
>> One idea worth pondering might be to provide a special struct
>> mii_if_info hookup (fully emulated mdio_read()/write())
>> for the case of the non-MII hardware types of this driver,
>> thus eliminating any added penalty in the case of nicely MII-complia=
nt
>> hardware.
>> But this should be tackled later, now let's better move on with eepr=
o100
>> (non-)plans...
>>
>> Andreas Mohr
>
> Given that 2.6.29-rc now actually has eepro100.c removed (since -rc3 =
or so)
> and the current -rc6 e100.c does not contain non-MII parts, it looks =
like
> 2.6.29 proper will actually remove support for some PCI-based non-MII
> e100 cards.
>
> Thus I'd like to ask what should be done about this for real.
> Of course we could consciously decide to simply skip e100.c support f=
or those
> non-MII cards entirely (hoping that they're not THAT wide-spread),
> but obviously I'd semi-hate this (nevermind the fact that _locally_
> I'd have to swap cards, too, which is somewhat more of a problem give=
n an
> older network requiring to be served by "combo" cards).
>
> Simply spoken, it all boils down to actively deciding
> what to do in the next, about-to-be _affected_, kernel version
> about support for cards that an older, deprecated driver did support
> and the new one doesn't.
>
> Or one could just let things progress as-is and wait for
> yet unknown (non-)amounts of scorching user feedback to arrive
> after 2.6.29 has hit their machines ;)
>
>
> My description in the mail above was meant to list things to be done
> _after_ an initial non-MII support for e100.c has been added,
> just for clarification.
>
> Thanks,
>
> Andreas Mohr
> --

I am personally sorry that nothing has been done regarding this patch.
 I still have this patch in my local tree.  I admit that this patch
has been on the low priority list, so I will make sure the patch is
current this week and respond accordingly this week.

--=20
Cheers,
Jeff
