From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC Patch] bonding: move to net/ directory
Date: Mon, 06 Jun 2011 19:04:41 +0200
Message-ID: <1307379881.3098.71.camel@edumazet-laptop>
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
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?ISO-8859-1?Q?Am=E9rico?= Wang <xiyou.wangcong@gmail.com>,
	Jeffrey Kirsher <jeffrey.t.kirsher@intel.com>,
	=?UTF-8?Q?Micha=C5=82_Miros=C5=82aw?= <mirqus@gmail.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	Andy Gospodarek <andy@greyhouse.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Jay Vosburgh <fubar@us.ibm.com>
To: Joe Perches <joe@perches.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:34622 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755956Ab1FFREq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Jun 2011 13:04:46 -0400
Received: by wwa36 with SMTP id 36so4028221wwa.1
        for <netdev@vger.kernel.org>; Mon, 06 Jun 2011 10:04:45 -0700 (PDT)
In-Reply-To: <1307379022.4994.4.camel@Joe-Laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 06 juin 2011 =C3=A0 09:50 -0700, Joe Perches a =C3=A9crit :
> On Tue, 2011-06-07 at 00:34 +0800, Am=C3=A9rico Wang wrote:
> > I agree with this, IMHO this would help to organize the code better=
=2E
> > And currently only tuntap and bonding are still in net/ directory.
> > In any aspects, now we are mixing net/ and drivers/net/ currently,
> > which could be improved.
>=20
> There is a proposal to move some drivers/net content to
> drivers/net/sw/
>=20
> http://vger.kernel.org/netconf2010_slides/netconf-jtk.pdf
>=20
> I think that'd be fine too.
>=20
> I believe Jeff is going to submit patches soonish.
>=20
> http://comments.gmane.org/gmane.linux.network/197232
>=20

As long as the re-organization is done without loosing "git blame"
information on current files, I am fine.

If not, this is a showstopper and not worth the pain, exactly like othe=
r
cleanup patches.



