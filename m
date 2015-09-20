From: =?UTF-8?Q?Nie=C5=9Bcierowicz_Adam?= <adam.niescierowicz@justnet.pl>
Subject: Re: sr-iov and bridges (mlx4)
Date: Sun, 20 Sep 2015 20:18:47 +0200
Message-ID: <8f15ec904f631f2d792388128b34732a@justnet.pl>
References: <55FDF69F.6000105@colorado.edu>
 <CAJ3xEMg1HR+WfhUNMCu9mnXp6F9Vuw8=VkrUvcynAn3VWoP2Gw@mail.gmail.com>
 <55FEDCFE.30506@colorado.edu>
Reply-To: adam.niescierowicz@justnet.pl
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Or Gerlitz <gerlitz.or@gmail.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	netdev-owner@vger.kernel.org
To: Matthew Monaco <Matthew.Monaco@colorado.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from justnet.pl ([195.54.47.50]:43773 "EHLO mail.justnet.pl"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1755343AbbITSws (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 20 Sep 2015 14:52:48 -0400
In-Reply-To: <55FEDCFE.30506@colorado.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Matthew,
in near future i want to do exactly the same, if you make progress with=
=20
SR-IOV+Bridge+OpenStack please leave here some advice.

---
Pozdrawiam
Adam Nie=C5=9Bcierowicz

W dniu 20.09.2015 18:21, Matthew Monaco napisa=C5=82(a):

> On 09/20/2015 05:01 AM, Or Gerlitz wrote: On Sun, Sep 20, 2015 at 2:5=
8=20
> AM, Matthew Monaco
> <Matthew.Monaco@colorado.edu> wrote:
> [...] In all cases, VMs with SR-IOV work fine, IP on the host works=20
> fine, outbound
> DHCP from the virtio VMs work fine, but inbound frames are not making=
=20
> it back to
> the VM. [...] Is there a know limitation of mixing SR-IOV and bridges=
=20
> in general? Does the
> SR-IOV switch specific to the mlx4 hardware not work well with linux=20
> bridges? ...?
> It would be a bit hard for bridge based promiscuous environment to wo=
rk=20
> OOB
> for one of the functions (PF or VF) in SRIOV, this is generic issue,
> and not related
> to specific vendor.
>=20
> You need to use the bridge (8) tool (part of iproute2) and add the P.=
V
> VM MACs to
> the PF interface as "self" see some slides (21/22/23) from netdev 0.1
> that deal with that
> https://netdev01.org/docs/netdev_tutorial_bridge_makita_150213.pdf [1=
]
>=20
> Or.
>=20
> It also possible to mark one bridge port (the PF) as non-promiscuous,
> but I haven't
> played with that myself yet (slide 32), so can't just send you doing=20
> it...

  Many thanks, that helps. Now to figure out the best approach for=20
shoving this
  into OpenStack =3D)



Links:
------
[1] https://netdev01.org/docs/netdev_tutorial_bridge_makita_150213.pdf
