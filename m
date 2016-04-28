From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: =?UTF-8?Q?Re=3A=20=5BPATCH=203=2E2=20085?=
 =?UTF-8?Q?/115=5D=20veth=3A=20don=E2=80=99t=20?=
 =?UTF-8?Q?modify=20ip=5Fsummed=3B=20?=
 =?UTF-8?Q?doing=20so=20treats=20pa?=
 =?UTF-8?Q?ckets=20with=20bad=20che?= =?UTF-8?Q?cksums=20as=20good=2E?=
Date: Thu, 28 Apr 2016 02:00:03 +0200
Message-ID: <1461801603.3971874.591751457.2DB91B98@webmail.messagingengine.com>
References: <lsq.1461711744.699003961@decadent.org.uk>
 <5720E1F0.9010203@candelatech.com>
 <1461780469.5102.0.camel@decadent.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: akpm@linux-foundation.org, "David S. Miller" <davem@davemloft.net>,
	Vijay Pandurangan <vijayp@vijayp.ca>,
	Cong Wang <cwang@twopensource.com>, netdev@vger.kernel.org,
	Evan Jones <ej@evanjones.ca>,
	Nicolas Dichtel <nicolas.dichtel@6wind.com>,
	Phil Sutter <phil@nwl.cc>,
	Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
To: Ben Hutchings <ben@decadent.org.uk>,
	Ben Greear <greearb@candelatech.com>,
	linux-kernel@vger.kernel.org, stable@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1461780469.5102.0.camel@decadent.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Ben,

On Wed, Apr 27, 2016, at 20:07, Ben Hutchings wrote:
> On Wed, 2016-04-27 at 08:59 -0700, Ben Greear wrote:
> > On 04/26/2016 04:02 PM, Ben Hutchings wrote:
> > >=20
> > > 3.2.80-rc1 review patch.=C2=A0=C2=A0If anyone has any objections,=
 please let me know.
> > I would be careful about this.=C2=A0=C2=A0It causes regressions whe=
n sending
> > PACKET_SOCKET buffers from user-space to veth devices.
> >=20
> > There was a proposed upstream fix for the regression, but it has no=
t gone
> > into the tree as far as I know.
> >=20
> > http://www.spinics.net/lists/netdev/msg370436.html
> [...]
>=20
> OK, I'll drop this for now.

The fall out from not having this patch is in my opinion a bigger
fallout than not having this patch. This patch fixes silent data
corruption vs. the problem Ben Greear is talking about, which might not
be that a common usage.

What do others think?

Bye,
Hannes
