From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [RFC Patch] bonding: move to net/ directory
Date: Tue, 24 May 2011 12:33:24 -0400
Message-ID: <20110524163323.GB28521@hmsreliant.think-freely.org>
References: <BANLkTimkxi0BofJYv_tRj8Et+OZFu+VfBw@mail.gmail.com>
 <20110523151336.GF21309@gospo.rdu.redhat.com>
 <BANLkTikT2HJyGb_4BOF+Ds1AAcJV+HVQ-w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andy Gospodarek <andy@greyhouse.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Jay Vosburgh <fubar@us.ibm.com>
To: =?iso-8859-1?Q?Am=E9rico?= Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:55875 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752309Ab1EXQdh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 May 2011 12:33:37 -0400
Content-Disposition: inline
In-Reply-To: <BANLkTikT2HJyGb_4BOF+Ds1AAcJV+HVQ-w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 24, 2011 at 10:00:23PM +0800, Am=E9rico Wang wrote:
> On Mon, May 23, 2011 at 11:13 PM, Andy Gospodarek <andy@greyhouse.net=
> wrote:
> > On Mon, May 23, 2011 at 08:45:14PM +0800, Am=E9rico Wang wrote:
> >> Hello, Jay, Andy,
> >>
> >> Is there any peculiar reason that bonding code has to stay
> >> in drivers/net/ directory?
> >>
> >> Since bonding and bridge are somewhat similar, both of
> >> which are used to "bond" two or more devices into one,
> >> and bridge code is already in net/bridge/, so I think it also
> >> makes sense to move bonding code into net/bonding/ too.
> >>
> >> This could also help to grep the source more easily. :)
> >>
> >> What do you think about the patch below?
> >> (Note, this patch is against net-next-2.6.)
> >>
> >
> > I would rather keep the code for bonding in drivers/net since it is
> > really a pure device (though not directly tied to any specific
> > hardware) rather than a device + forwarding or management code.
>=20
> Is this a reason strong enough to leave it to drivers/net/ ?
> I think it is generic enough to be moved to net/ directory... :-/
>=20
> >
> > It has bothered me for a long time that the code just to manage the=
 VLAN
> > and bridge devices sits outside of drivers/net, but I've never prop=
osed
> > a patch to move the files as I suspect the maintainers of that code
> > would like to keep it all together. =A0Maybe it is time to do that.
> >
>=20
> You mean move net/8021q/ to drivers/net/8021q/ ?
>=20
This all sounds like change for the sake of change to me.  I don't see =
any
compelling argument for moving bonding (or bridging or vlans, etc) arou=
nd at
all.  All of these software drivers have feet in multple subsystems, bu=
t that
just means that theres not going to be a compelling argument to move th=
em any
place,  at least not without an immediate subsequent argument that it r=
eally
belonged back where it was.  Unless you can show a solid benefit to mov=
ing the
code, I don't see why any reorganization is needed.=20

Neil

> Thanks!
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>=20
