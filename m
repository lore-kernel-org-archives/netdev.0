From: Liviu Dudau <Liviu.Dudau@arm.com>
Subject: Re: [PATCH] sky2: Add module parameter for passing the MAC address
Date: Thu, 6 Aug 2015 11:31:49 +0100
Message-ID: <20150806103149.GJ20890@e106497-lin.cambridge.arm.com>
References: <1438789854-29194-1-git-send-email-Liviu.Dudau@arm.com>
 <20150805.173233.539752020022715092.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "mlindner@marvell.com" <mlindner@marvell.com>,
	"stephen@networkplumber.org" <stephen@networkplumber.org>,
	"ryan.harkin@linaro.org" <ryan.harkin@linaro.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu-smtp-delivery-143.mimecast.com ([146.101.78.143]:62293 "EHLO
	eu-smtp-delivery-143.mimecast.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754734AbbHFKbw convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 6 Aug 2015 06:31:52 -0400
In-Reply-To: <20150805.173233.539752020022715092.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 06, 2015 at 01:32:33AM +0100, David Miller wrote:
> From: Liviu Dudau <Liviu.Dudau@arm.com>
> Date: Wed,  5 Aug 2015 16:50:54 +0100
>=20
> > For designs where EEPROMs are not connected to PCI Yukon2
> > chips we need to get the MAC address from the firmware.
> > Add a module parameter called 'mac_address' for this. It
> > will be used if no DT node can be found and the B2_MAC
> > register holds an invalid value.
> >=20
> > Signed-off-by: Liviu Dudau <Liviu.Dudau@arm.com>
>=20
> Sorry, such module options are absolutely not allowed.

Please clarify if this is a drivers/net/ethernet policy or=20
that is true for the larger subsystem. There are a few
networking drivers that have a mac_addr module parameter. I
personally used drivers/net/ethernet/8390/pcnet_cs.c as inspiration
for my patch.

>=20
> If an invalid MAC is present, it should be set to a random
> one via eth_random_addr().
>=20

Understood. Stephen Hemminger has provided a patch that I can try
and I will report back with the results.

Best regards,
Liviu

--=20
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
| I would like to |
| fix the world,  |
| but they're not |
| giving me the   |
 \ source code!  /
  ---------------
    =C2=AF\_(=E3=83=84)_/=C2=AF
