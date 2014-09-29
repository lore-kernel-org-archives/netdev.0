From: Michal Kubecek <mkubecek@suse.cz>
Subject: Re: Regarding bug 82471
Date: Mon, 29 Sep 2014 07:51:56 +0200
Message-ID: <20140929055156.GA13693@unicorn.suse.cz>
References: <542595D6.6040904@lncsa.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-2
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Laurent CARON <lcaron@lncsa.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor2.suse.de ([195.135.220.15]:48834 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750936AbaI2FwE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Sep 2014 01:52:04 -0400
Content-Disposition: inline
In-Reply-To: <542595D6.6040904@lncsa.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 26, 2014 at 06:35:34PM +0200, Laurent CARON wrote:
> Hi,
>=20
> I've been biten by :
> https://bugzilla.kernel.org/show_bug.cgi?id=3D82471 today.
>=20
> I tried various kernels from 3.2.0 to 3.16.3
>=20
> The last unaffected kernel according to my tests is 3.14 (didn't yet
> try 3.15).
>=20
> Please see logs when (on 3.16.2)
> 1/ using iptables
> 2/ having some traffic (even light) going through
>=20
> http://pastebin.com/JWkFu2w2
>=20
> My network config is the following:
>=20
> a bond interface consisting of 2 10Gb ports (intel ixgbe / X520-SR2)
> on top of which I use 2 vlans.

I don't see why it would affect ixgbe adapters which support Tx VLAN
offloading (and with which the original patch was tested) but the
symptoms look very much like those fixed by commit db115037bb57 ("net:
fix checksum features handling in netif_skb_features()"). Could you
please test with 3.17-rc5 or later?

                                                      Michal Kube=E8ek
