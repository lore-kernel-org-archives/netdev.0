From: WANG Cong <xiyou.wangcong@gmail.com>
Subject: Re: [RFC Patch] bonding: move to net/ directory
Date: Sat, 18 Jun 2011 02:48:18 +0000 (UTC)
Message-ID: <ith3li$16c$1@dough.gmane.org>
References: <BANLkTimkxi0BofJYv_tRj8Et+OZFu+VfBw@mail.gmail.com>
	<20110523151336.GF21309@gospo.rdu.redhat.com>
	<BANLkTikT2HJyGb_4BOF+Ds1AAcJV+HVQ-w@mail.gmail.com>
	<20110524163323.GB28521@hmsreliant.think-freely.org>
	<BANLkTinoRXmEAp0mbZdxSmMbntsE-QeRsQ@mail.gmail.com>
	<20110525152023.GC11867@hmsreliant.think-freely.org>
	<BANLkTin2HaYjHgGACkwvKwuY-Y_e3+r3JQ@mail.gmail.com>
	<20110526135053.GB12617@hmsreliant.think-freely.org>
	<BANLkTikrsr5sZ4aZ5aEmfBSvPE0mEL8g0g@mail.gmail.com>
	<BANLkTin4VyK3boPqDQnd+Dkv6==cHww9PA@mail.gmail.com>
	<1307379022.4994.4.camel@Joe-Laptop>
	<1307381465.2698.5740.camel@jtkirshe-linux>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lo.gmane.org ([80.91.229.12]:44223 "EHLO lo.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751093Ab1FRCsc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 17 Jun 2011 22:48:32 -0400
Received: from list by lo.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1QXlaI-0005vG-Ie
	for netdev@vger.kernel.org; Sat, 18 Jun 2011 04:48:30 +0200
Received: from 123.124.21.93 ([123.124.21.93])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Sat, 18 Jun 2011 04:48:30 +0200
Received: from xiyou.wangcong by 123.124.21.93 with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Sat, 18 Jun 2011 04:48:30 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 06 Jun 2011 10:31:05 -0700, Jeff Kirsher wrote:

> On Mon, 2011-06-06 at 09:50 -0700, Joe Perches wrote:
>> On Tue, 2011-06-07 at 00:34 +0800, Am=C3=A9rico Wang wrote:
>> > I agree with this, IMHO this would help to organize the code bette=
r.
>> > And currently only tuntap and bonding are still in net/ directory.=
 In
>> > any aspects, now we are mixing net/ and drivers/net/ currently, wh=
ich
>> > could be improved.
>>=20
>> There is a proposal to move some drivers/net content to drivers/net/=
sw/
>>=20
>> http://vger.kernel.org/netconf2010_slides/netconf-jtk.pdf
>>=20
>> I think that'd be fine too.
>>=20
>> I believe Jeff is going to submit patches soonish.
>>=20
>> http://comments.gmane.org/gmane.linux.network/197232
>>=20
>>=20
>>=20
> Correct, patches will be sent out here this week.
>=20

But I still don't see them so far... :-/ Can you Cc me as well?

> As far as moving tunap, bonding, etc into /drivers/net/sw that is the
> eventual plan, but I have not done this work for this upcoming patchs=
et.
> I want to coordinate this work with Stephen Hemminger before I do any
> moves.

Is net/bridge =3D=3D> drivers/net/sw/bridge in your plan too?

