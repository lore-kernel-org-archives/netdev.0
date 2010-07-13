From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] tproxy: nf_tproxy_assign_sock() can handle tw sockets
Date: Tue, 13 Jul 2010 16:40:23 +0200
Message-ID: <1279032023.2634.384.camel@edumazet-laptop>
References: <AANLkTimn8A0cYZmwNZYitRkBHKKFe4HQ5GU626DLugkk@mail.gmail.com>
	 <AANLkTil49m6Ul2bauiH4Pwn-6ykrYTFmSO6_SxqQgD_e@mail.gmail.com>
	 <1278626921.2435.73.camel@edumazet-laptop>
	 <AANLkTiliBClahTfb41M5BDi1etg5pgkqEz_VfGrn_mK4@mail.gmail.com>
	 <1278695580.2696.55.camel@edumazet-laptop>
	 <AANLkTil39xHOhcdAo4h_jWtx_UuYdFHGdQVAdwPMd7QJ@mail.gmail.com>
	 <1278742649.2538.17.camel@edumazet-laptop> <4C395459.6080407@redhat.com>
	 <1278835332.2538.51.camel@edumazet-laptop>
	 <AANLkTikEGuFtTlIKUfti6GDsdBz99PpKRCs5lEeEM86u@mail.gmail.com>
	 <AANLkTilbEkJWPqvJE72r9HdFQSU84S02BKZB0CH-8QwB@mail.gmail.com>
	 <AANLkTimn9x17g-4K7fS4MjmCgzHuBARurEoFVd_gId7m@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Avi Kivity <avi@redhat.com>, David Miller <davem@davemloft.net>,
	Patrick McHardy <kaber@trash.net>,
	linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: Felipe W Damasio <felipewd@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:48053 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756563Ab0GMOka (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jul 2010 10:40:30 -0400
In-Reply-To: <AANLkTimn9x17g-4K7fS4MjmCgzHuBARurEoFVd_gId7m@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 13 juillet 2010 =C3=A0 11:24 -0300, Felipe W Damasio a =C3=A9c=
rit :
> Hi Mr. Dumazet,
>=20
> 2010/7/12 Felipe W Damasio <felipewd@gmail.com>:
> > Here's the result using ethtool-2.6.34:
> >
> > ./ethtool -k eth1
> >
> > Offload parameters for eth1:
> > rx-checksumming: on
> > tx-checksumming: on
> > scatter-gather: on
> > tcp-segmentation-offload: on
> > udp-fragmentation-offload: off
> > generic-segmentation-offload: on
> > generic-receive-offload: off
> > large-receive-offload: off
> > ntuple-filters: off
> > receive-hashing: off
> >
> >
> > ./ethtool -k eth2
> >
> > Offload parameters for eth2:
> > rx-checksumming: on
> > tx-checksumming: on
> > scatter-gather: on
> > tcp-segmentation-offload: on
> > udp-fragmentation-offload: off
> > generic-segmentation-offload: on
> > generic-receive-offload: off
> > large-receive-offload: off
> > ntuple-filters: off
> > receive-hashing: off
>=20
> Did these help you track down the issue?
>=20
> Sorry to insist, it's just that my bosses are kind of pressuring me t=
o
> solve the problem and put the squid machine back online :-)
>=20
> Is there a test I can run to try and trigger the issue?
>=20
> I have the same scenario (hardware and network setup) on my lab...
>=20

I currently have no fresh ideas. If you want this problem to be solved,
its important to setup in your lab a workload to trigger again and agai=
n
the bug, in order to provide us more crash information.

After code review doesnt spot obvious bugs, this is time for brute forc=
e
hunting, using git bisection for example...



