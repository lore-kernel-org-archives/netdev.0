From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ixgbe: refactor ixgbe_alloc_queues()
Date: Fri, 29 Oct 2010 10:48:58 +0200
Message-ID: <1288342138.2560.1.camel@edumazet-laptop>
References: <1286799439.2737.21.camel@edumazet-laptop>
	 <EA929A9653AAE14F841771FB1DE5A136602807B460@rrsmsx501.amr.corp.intel.com>
	 <1288239858.2658.72.camel@edumazet-laptop>
	 <1288267354.2649.369.camel@edumazet-laptop>
	 <1288268493.27890.5.camel@jtkirshe-MOBL1>
	 <1288323933.2711.43.camel@edumazet-laptop>
	 <AANLkTinKQccHsA++PG86h5x3smJx75EB05YnHq2tGM-R@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Tantilov, Emil S" <emil.s.tantilov@intel.com>,
	David Miller <davem@davemloft.net>,
	"Waskiewicz Jr, Peter P" <peter.p.waskiewicz.jr@intel.com>,
	"Brattain, Ross B" <ross.b.brattain@intel.com>,
	netdev <netdev@vger.kernel.org>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:48388 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756353Ab0J2ItD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Oct 2010 04:49:03 -0400
Received: by wwe15 with SMTP id 15so3007424wwe.1
        for <netdev@vger.kernel.org>; Fri, 29 Oct 2010 01:49:01 -0700 (PDT)
In-Reply-To: <AANLkTinKQccHsA++PG86h5x3smJx75EB05YnHq2tGM-R@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 29 octobre 2010 =C3=A0 01:38 -0700, Jeff Kirsher a =C3=A9cr=
it :

>=20
> I noticed a typo when applying the patch and I fixed it in the patch
> in my queue.
>=20
> The following code:
> > +       while (rx)
> > +               kfree(adapter->tx_ring[--rx]);
> > +
>=20
> should be:
> > +       while (rx)
> > +               kfree(adapter->rx_ring[--rx]);
> > +
>=20

Good catch, thanks !


