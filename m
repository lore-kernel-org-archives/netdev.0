From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [patch net-next RFC 0/4] introduce infrastructure for support of
 switch chip datapath
Date: Wed, 2 Apr 2014 16:06:39 -0400
Message-ID: <20140402200639.GD3301@tuxdriver.com>
References: <53330639.8050403@cumulusnetworks.com>
 <20140326165934.GH2869@minipsycho.orion>
 <533312A3.5070600@cumulusnetworks.com>
 <20140326180356.GK2869@minipsycho.orion>
 <2D65D0C2-6BBC-4968-8400-4EB60BDF887A@cumulusnetworks.com>
 <533C1F91.6000704@greyhouse.net>
 <20140402152546.GB3596@tuxdriver.com>
 <CD1A9D96-F1E1-4AF6-B089-41AEBF7F1699@cumulusnetworks.com>
 <20140402192915.GB3301@tuxdriver.com>
 <3C265410-A9DF-489F-BC55-05B231564D12@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Andy Gospodarek <andy@greyhouse.net>,
	Jiri Pirko <jiri@resnulli.us>,
	Roopa Prabhu <roopa@cumulusnetworks.com>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Florian Fainelli <f.fainelli@gmail.com>,
	Neil Horman <nhorman@tuxdriver.com>,
	Thomas Graf <tgraf@suug.ch>, netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	dborkman <dborkman@redhat.com>, ogerlitz <ogerlitz@mellanox.com>,
	jesse <jesse@nicira.com>, pshelar <pshelar@nicira.com>,
	azhou <azhou@nicira.com>, Ben Hutchings <ben@decadent.org.uk>,
	Stephen Hemminger <stephen@networkplumber.org>,
	jeffrey.t.kirsher@intel.com, vyasevic <vyasevic@redhat.com>,
	Cong Wang <xiyou.wangcong@gmail.com>,
	John Fastabend <john.r.fastabend@intel.com>,
	Eric Dumazet <edumazet@google.com>,
	Lennert Buytenhek <buytenh@wantstofly.org>,
	Shrijeet Mukherjee <shm@cumulusnetworks.com>
To: Scott Feldman <sfeldma@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:39765 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030187AbaDBUbC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Apr 2014 16:31:02 -0400
Content-Disposition: inline
In-Reply-To: <3C265410-A9DF-489F-BC55-05B231564D12@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Apr 02, 2014 at 12:54:50PM -0700, Scott Feldman wrote:
>=20
> On Apr 2, 2014, at 12:29 PM, John W. Linville <linville@tuxdriver.com=
> wrote:
>=20
> > Cool!  I'm glad we agree.  Now we just need some switch hardware
> > drivers that fit the general model outlined above...
>=20
> Why wait?  Let=E2=80=99s create a switch device in qemu and then writ=
e the
> model/sample driver to that.  Put a PCI front end on the qemu device
> which is mapped to kernel, and define a register set to represent all
> the switch-like ops we want to offload, in a generic way.  Throw in
> some DMA for CPU-bound I/O (ctrl traffic).  On the qemu device back
> end, expose the ports as taps or whatever so we can wire to real-worl=
d
> link partners on the host side.

Not a bad idea at all.  This probably needs further discussion and/or
a spec...and a QEMU hacker.  Where is my friend PJ when I need him? ;-)

> > I would be happy to maintain a kernel.org git tree as a nursery for
> > such drivers as they develop and mature, and I'm sure my daytime
> > employer would be happy to support me on that.  I wonder if we can
> > get any switch people from Intel, Mellanox, Broadcom, or elsewhere
> > to play along?
>=20
> My gut tells me this is a build-it-and-they-will-come situation.

No doubt -- in the meantime, feel free to Cc me on some patches!

John
--=20
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
