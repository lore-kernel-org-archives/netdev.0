From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: [RFC Patch] bonding: move to net/ directory
Date: Mon, 23 May 2011 11:13:36 -0400
Message-ID: <20110523151336.GF21309@gospo.rdu.redhat.com>
References: <BANLkTimkxi0BofJYv_tRj8Et+OZFu+VfBw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>
To: =?iso-8859-1?Q?Am=E9rico?= Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:38792 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755850Ab1EWPNx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 May 2011 11:13:53 -0400
Content-Disposition: inline
In-Reply-To: <BANLkTimkxi0BofJYv_tRj8Et+OZFu+VfBw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, May 23, 2011 at 08:45:14PM +0800, Am=E9rico Wang wrote:
> Hello, Jay, Andy,
>=20
> Is there any peculiar reason that bonding code has to stay
> in drivers/net/ directory?
>=20
> Since bonding and bridge are somewhat similar, both of
> which are used to "bond" two or more devices into one,
> and bridge code is already in net/bridge/, so I think it also
> makes sense to move bonding code into net/bonding/ too.
>=20
> This could also help to grep the source more easily. :)
>=20
> What do you think about the patch below?
> (Note, this patch is against net-next-2.6.)
>=20

I would rather keep the code for bonding in drivers/net since it is
really a pure device (though not directly tied to any specific
hardware) rather than a device + forwarding or management code.

It has bothered me for a long time that the code just to manage the VLA=
N
and bridge devices sits outside of drivers/net, but I've never proposed
a patch to move the files as I suspect the maintainers of that code
would like to keep it all together.  Maybe it is time to do that.
