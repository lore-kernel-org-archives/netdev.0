From: Simon Guinot <simon.guinot@sequanux.org>
Subject: Re: [PATCH v9 0/8] thunderbolt: Introducing Thunderbolt(TM)
 Networking
Date: Tue, 22 Nov 2016 18:28:28 +0100
Message-ID: <20161122172828.GB31492@kw.sim.vm.gnt>
References: <1478701208-4585-1-git-send-email-amir.jer.levy@intel.com>
 <20161109143632.GE6167@kw.sim.vm.gnt>
 <E607265CB020454880711A6F96C05A03B677E4C9@hasmsx107.ger.corp.intel.com>
 <20161115105920.GH6167@kw.sim.vm.gnt>
 <E607265CB020454880711A6F96C05A03BE2199EE@hasmsx108.ger.corp.intel.com>
 <20161118112007.GB1230@kw.sim.vm.gnt>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="8GpibOaaTibBMecb"
Cc: "gregkh@linuxfoundation.org" <gregkh@linuxfoundation.org>,
        "andreas.noever@gmail.com" <andreas.noever@gmail.com>,
        "bhelgaas@google.com" <bhelgaas@google.com>,
        "corbet@lwn.net" <corbet@lwn.net>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        "linux-pci@vger.kernel.org" <linux-pci@vger.kernel.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>,
        "mario_limonciello@dell.com" <mario_limonciello@dell.com>,
        thunderbolt-linux <thunderbolt-linux@intel.com>,
        "Westerberg, Mika" <mika.westerberg@intel.com>,
        "Winkler, Tomas" <tomas.winkler@intel.com>,
        "Zhang, Xiong Y" <xiong.y.zhang@intel.com>,
        "Jamet, Michael" <michael.jamet@intel.com>,
        "remi.rerolle@seagate.com" <remi.rerolle@seagate.com>
To: "Levy, Amir (Jer)" <amir.jer.levy@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20161118112007.GB1230@kw.sim.vm.gnt>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--8GpibOaaTibBMecb
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, Nov 18, 2016 at 12:20:07PM +0100, Simon Guinot wrote:
> On Fri, Nov 18, 2016 at 08:48:36AM +0000, Levy, Amir (Jer) wrote:
> > On Tue, Nov 15 2016, 12:59 PM, Simon Guinot wrote:
> > > On Wed, Nov 09, 2016 at 03:42:53PM +0000, Levy, Amir (Jer) wrote:
> > > > On Wed, Nov 9 2016, 04:36 PM, Simon Guinot wrote:
> > > > > Hi Amir,
> > > > >
> > > > > I have an ASUS "All Series/Z87-DELUXE/QUAD" motherboard with a=20
> > > > > Thunderbolt 2 "Falcon Ridge" chipset (device ID 156d).
> > > > >
> > > > > Is the thunderbolt-icm driver supposed to work with this chipset ?
> > > > >
> > > >
> > > > Yes, the thunderbolt-icm supports Falcon Ridge, device ID 156c.
> > > > 156d is the bridge -
> > > > http://lxr.free-electrons.com/source/include/linux/pci_ids.h#L2619
> > > >
> > > > > I have installed both a 4.8.6 Linux kernel (patched with your v9
> > > > > series) and the thunderbolt-software-daemon (27 october release)=
=20
> > > > > inside a Debian system (Jessie).
> > > > >
> > > > > If I connect the ASUS motherboard with a MacBook Pro (Thunderbolt=
=20
> > > > > 2, device ID 156c), I can see that the thunderbolt-icm driver is=
=20
> > > > > loaded and that the thunderbolt-software-daemon is well started.=
=20
> > > > > But the Ethernet interface is not created.
> > > > >
> > > > > I have attached to this email the syslog file. There is the logs=
=20
> > > > > from both the kernel and the daemon inside. Note that the daemon=
=20
> > > > > logs are everything but clear about what could be the issue. Mayb=
e=20
> > > > > I missed some kind of configuration ? But I failed to find any=20
> > > > > valuable information about configuring the driver and/or the=20
> > > > > daemon in
> > > the various documentation files.
> > > > >
> > > > > Please, can you provide some guidance ? I'd really like to test=
=20
> > > > > your patch series.
> > > >
> > > > First, thank you very much for willing to test it.
> > > > Thunderbolt Networking support was added during Falcon Ridge, in the
> > > latest FR images.
> > > > Do you know which Thunderbolt image version you have on your system?
> > > > Currently I submitted only Thunderbolt Networking feature in Linux,=
=20
> > > > and we plan to add more features like reading the image version and
> > > updating the image.
> > > > If you don't know the image version, the only thing I can suggest i=
s=20
> > > > to load windows, install thunderbolt SW and check in the Thunderbolt
> > > application the image version.
> > > > To know if image update is needed, you can check -=20
> > > > https://thunderbolttechnology.net/updates
> > >=20
> > > Hi Amir,
> > >=20
> > > From the Windows Thunderbolt software, I can read 13.00 for the=20
> > > firmware version. And from https://thunderbolttechnology.net/updates,=
=20
> > > I can see that there is no update available for my ASUS motherboard.
> > >=20
> > > Am I good to go ?
> > >=20
> >=20
> > Thunderbolt Networking is supported on both Thunderbolt(tm) 2 and Thund=
erbolt(tm) 3 systems. =20
> > Thunderbolt 2 systems must have updated NVM (version 25 or later) in or=
der for the functionality to work properly. =20
> > If the system does not have the update, please contact the OEM directly=
 for an updated NVM. =20
> > For best functionality and support, Intel recommends using Thunderbolt =
3 systems for all validation and testing.
>=20
> Maybe it is worth mentioning in the documentation and/or in the Kconfig
> help message that a minimal firmware version is needed for Thunderbolt 2
> controllers.
>=20
> It would have saved some time for me :)
>=20
> >=20
> > > BTW, it is quite a shame that the Thunderbolt firmware version can't=
=20
> > > be read from Linux.
> > >=20
> >=20
> > This is WIP, once this patch will be upstream, we will be able to focus=
 more
> > on aligning Linux with the Thunderbolt features that we have for window=
s.
>=20
> Well, I rather see the firmware identification and update as basic
> features on the top of which ones you can build a driver. For example in
> this case this would allow the ICM driver and/or the userland daemon to
> exit with a useful error message rather than just not working without any
> explanation.
>=20
> Next week I'll try the driver with a Thunderbolt 3 controller.

Hi Amir,

I tested the thunderbolt-icm driver (v9 series) on an Gigabyte
motherboard (Z170X-UD5 TH-CF) with a Thunderbolt 3 controller (Alpine
Ridge 4C).

I can see that the network interface is well created when the
motherboard is connected to a MacBook Pro (Thunderbolt 2 or 3).

And here are the TCP bandwidths measured using the iperf3 benchmark:

- MacBook Pro Thunderbolt 2: 8.46Gbits/sec
- MacBook Pro Thunderbolt 3: 11.8Gbits/sec

Are this results consistent with your expectations ?

=46rom the MacOS system interface on the MacBook Pro Thunderbolt 3,
I noticed that the interface appears as dual lane (2x 20Gb/sec). But
when two MacBook Pro are connected together, the interface appears as
single lane (1x 40Gb/sec). Is some lane bonding support missing in the
Linux implementation ?

Here are a couple of additional questions:

- When the network interface is created, there is no IP address
  assigned (or negotiated ?) on the Linux side. But it is done on the
  MacOS side. And in the Linux kernel logs I can also read the message:
  "ready for ThunderboltIP negotiation". Is there something missing or
  not working on the Linux side ? What is the correct way to configure
  or negotiate the IP address. For my tests I did it manually...

- When the Linux machine is started with the Thunderbolt wire already
  connected to a MacBook Pro, sometimes (but not every time) the
  network interface is not created. The Thunderbolt wire needs to be
  replugged.

FWIW you get my

Tested-by: Simon Guinot <simon.guinot@sequanux.org>

Simon

--8GpibOaaTibBMecb
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlg0gDwACgkQgtp0PDeOcDp06wCgmAPcvwtpkxCeV9fl1mknFyLr
oPgAn0pOewyU6lYaCEk1RFr4Y+xgfLXK
=4JKx
-----END PGP SIGNATURE-----

--8GpibOaaTibBMecb--
