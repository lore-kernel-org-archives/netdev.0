From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCH 1/2] bridge: leave carrier on for empty bridge
Date: Fri, 2 Sep 2011 15:11:00 -0700
Message-ID: <20110902151100.327af0bf@nehalam.ftrdhcpuser.net>
References: <20110902172220.830228928@vyatta.com>
	<20110902172247.396753508@vyatta.com>
	<4E614CF7.7030700@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Nicolas de =?ISO-8859-1?B?UGVzbG/8YW4=?=
	<nicolas.2p.debian@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:36232 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756101Ab1IBWKt convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Sep 2011 18:10:49 -0400
In-Reply-To: <4E614CF7.7030700@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 02 Sep 2011 23:39:03 +0200
Nicolas de Peslo=FCan <nicolas.2p.debian@gmail.com> wrote:

> Le 02/09/2011 19:22, Stephen Hemminger a =E9crit :
> > This resolves a regression seen by some users of bridging.
> > Some users use the bridge like a dummy device.
> > They expect to be able to put an IPv6 address on the device
> > with no ports attached during boot.
> >
> > Note: the bridge still will reflect the state of ports in the
> > bridge if there are any added.
>=20
> Doesn't this jeopardize the behavior introduced in 1faa4356a3bd89ea11=
fb92752d897cff3a20ec0e
> "bridge: control carrier based on ports online"?
>=20
> If the user starts the DHCP client before adding the first port to th=
e bridge, the DHCP client will=20
> have a carrier and start the autoconfiguration process. This was the =
old behavior, but you fixed it.
>=20
> 	Nicolas.
>=20

There is no perfect solution.
If DHCP works then IPv6 breaks?
