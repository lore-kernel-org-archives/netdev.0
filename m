From: Liviu Dudau <Liviu.Dudau@arm.com>
Subject: Re: [PATCH] sky2: Add module parameter for passing the MAC address
Date: Wed, 5 Aug 2015 18:16:53 +0100
Message-ID: <20150805171652.GG20890@e106497-lin.cambridge.arm.com>
References: <1438789854-29194-1-git-send-email-Liviu.Dudau@arm.com>
 <20150805094057.59260077@urahara>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Mirko Lindner <mlindner@marvell.com>,
	"ryan.harkin@linaro.org" <ryan.harkin@linaro.org>,
	netdev <netdev@vger.kernel.org>,
	lkml <linux-kernel@vger.kernel.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20150805094057.59260077@urahara>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Aug 05, 2015 at 05:40:57PM +0100, Stephen Hemminger wrote:
> On Wed,  5 Aug 2015 16:50:54 +0100
> Liviu Dudau <Liviu.Dudau@arm.com> wrote:
>=20
> > For designs where EEPROMs are not connected to PCI Yukon2
> > chips we need to get the MAC address from the firmware.
> > Add a module parameter called 'mac_address' for this. It
> > will be used if no DT node can be found and the B2_MAC
> > register holds an invalid value.
> >=20
> > Signed-off-by: Liviu Dudau <Liviu.Dudau@arm.com>
>=20
> Yes, I can see that this can be a real problem, and other drivers
> solve the problem. The standard method is to assign a random mac addr=
ess
> (and then let scripts overwrite) rather than introducing module param=
eter.
> Module parameters are discouraged because they are device specific.
>=20

I agree. However, in my case, the boards people have assigned MAC addre=
sses
to the chip, they just didn't built the board in such a way as to allow=
 one
to store that MAC address in a permanent way :( And no, I can't use the=
 DT
because the chip is actually on the PCIe bus.

Even with the generation of a random address, it still needs to be copi=
ed
into the device, so I would guess that a version of the patch I've sent=
 is
still relevant?

Best regards,
Liviu

> =20
>=20

--=20
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
| I would like to |
| fix the world,  |
| but they're not |
| giving me the   |
 \ source code!  /
  ---------------
    =C2=AF\_(=E3=83=84)_/=C2=AF
