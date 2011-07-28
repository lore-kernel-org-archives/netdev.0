From: "Rose, Gregory V" <gregory.v.rose@intel.com>
Subject: RE: [RFC net-next PATCH 4/4] ixgbe: Add support for new ethtool
 settings
Date: Thu, 28 Jul 2011 08:52:18 -0700
Message-ID: <43F901BD926A4E43B106BF17856F0755019414D50E@orsmsx508.amr.corp.intel.com>
References: <20110727221406.8435.44324.stgit@gitlad.jf.intel.com>
 <20110727221804.8435.97686.stgit@gitlad.jf.intel.com>
 <CAHXqBFJ30LLV=dgWuSK73rhxYLt5xoVFVwHdU3cWFmr_Yxs5pg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"bhutchings@solarflare.com" <bhutchings@solarflare.com>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
To: =?iso-8859-2?Q?Micha=B3_Miros=B3aw?= <mirqus@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:9968 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755683Ab1G1PwV convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Jul 2011 11:52:21 -0400
In-Reply-To: <CAHXqBFJ30LLV=dgWuSK73rhxYLt5xoVFVwHdU3cWFmr_Yxs5pg@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Micha=B3 Miros=B3aw [mailto:mirqus@gmail.com]
> Sent: Thursday, July 28, 2011 4:54 AM
> To: Rose, Gregory V
> Cc: netdev@vger.kernel.org; davem@davemloft.net;
> bhutchings@solarflare.com; Kirsher, Jeffrey T
> Subject: Re: [RFC net-next PATCH 4/4] ixgbe: Add support for new etht=
ool
> settings
>=20
> 2011/7/28 Greg Rose <gregory.v.rose@intel.com>:
> > Adds ixgbe driver support for new ethtool settings for SR-IOV re-in=
it,
> > number of VM queues and anti-spoofing ON/OFF switch.
> [...]
> > +static int ixgbe_reinit_sriov(struct net_device *netdev, int new_v=
fs)
> > +{
> [...]
> > +       if (adapter->flags & IXGBE_FLAG_SRIOV_ENABLED) {
> > +               adapter->flags &=3D ~(IXGBE_FLAG_RSS_ENABLED |
> > +                                   IXGBE_FLAG_DCB_ENABLED);
> > +               netdev->features &=3D ~NETIF_F_RXHASH;
> > +       } else {
> > +               adapter->flags |=3D IXGBE_FLAG_RSS_ENABLED;
> > +               netdev->features |=3D NETIF_F_RXHASH;
> > +       }
>=20
> Please use ndo_fix_features/ndo_set_features callbacks for this.

OK, sure.  I'll add a separate patch to do that.

- Greg

