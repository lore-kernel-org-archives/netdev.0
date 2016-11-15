From: Simon Guinot <simon.guinot@sequanux.org>
Subject: Re: [PATCH v9 0/8] thunderbolt: Introducing Thunderbolt(TM)
 Networking
Date: Tue, 15 Nov 2016 11:59:21 +0100
Message-ID: <20161115105920.GH6167@kw.sim.vm.gnt>
References: <1478701208-4585-1-git-send-email-amir.jer.levy@intel.com>
 <20161109143632.GE6167@kw.sim.vm.gnt>
 <E607265CB020454880711A6F96C05A03B677E4C9@hasmsx107.ger.corp.intel.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="nhAUiXSLan16V5i8"
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
        remi.rerolle@seagate.com
To: "Levy, Amir (Jer)" <amir.jer.levy@intel.com>
Return-path: <linux-pci-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <E607265CB020454880711A6F96C05A03B677E4C9@hasmsx107.ger.corp.intel.com>
Sender: linux-pci-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--nhAUiXSLan16V5i8
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Wed, Nov 09, 2016 at 03:42:53PM +0000, Levy, Amir (Jer) wrote:
> On Wed, Nov 9 2016, 04:36 PM, Simon Guinot wrote:
> > On Wed, Nov 09, 2016 at 04:20:00PM +0200, Amir Levy wrote:
> > > This driver enables Thunderbolt Networking on non-Apple platforms=20
> > > running Linux.
> > >
> > > Thunderbolt Networking provides peer-to-peer connections to transfer=
=20
> > > files between computers, perform PC migrations, and/or set up small=
=20
> > > workgroups with shared storage.
> > >
> > > This is a virtual connection that emulates an Ethernet adapter that=
=20
> > > enables Ethernet networking with the benefit of Thunderbolt=20
> > > superfast medium capability.
> > >
> > > Thunderbolt Networking enables two hosts and several devices that=20
> > > have a Thunderbolt controller to be connected together in a linear=20
> > > (Daisy
> > > chain) series from a single port.
> > >
> > > Thunderbolt Networking for Linux is compatible with Thunderbolt=20
> > > Networking on systems running macOS or Windows and also supports=20
> > > Thunderbolt generation 2 and 3 controllers.
> > >
> > > Note that all pre-existing Thunderbolt generation 3 features, such=20
> > > as USB, Display and other Thunderbolt device connectivity will=20
> > > continue to function exactly as they did prior to enabling Thunderbol=
t Networking.
> > >
> > > Code and Software Specifications:
> > > This kernel code creates a virtual ethernet device for computer to=20
> > > computer communication over a Thunderbolt cable.
> > > The new driver is a separate driver to the existing Thunderbolt drive=
r.
> > > It is designed to work on systems running Linux that interface with=
=20
> > > Intel Connection Manager (ICM) firmware based Thunderbolt=20
> > > controllers that support Thunderbolt Networking.
> > > The kernel code operates in coordination with the Thunderbolt user-=
=20
> > > space daemon to implement full Thunderbolt networking functionality.
> > >
> > > Hardware Specifications:
> > > Thunderbolt Hardware specs have not yet been published but are used=
=20
> > > where necessary for register definitions.
> >=20
> > Hi Amir,
> >=20
> > I have an ASUS "All Series/Z87-DELUXE/QUAD" motherboard with a=20
> > Thunderbolt 2 "Falcon Ridge" chipset (device ID 156d).
> >=20
> > Is the thunderbolt-icm driver supposed to work with this chipset ?
> >=20
>=20
> Yes, the thunderbolt-icm supports Falcon Ridge, device ID 156c.
> 156d is the bridge - http://lxr.free-electrons.com/source/include/linux/p=
ci_ids.h#L2619
>=20
> > I have installed both a 4.8.6 Linux kernel (patched with your v9
> > series) and the thunderbolt-software-daemon (27 october release)=20
> > inside a Debian system (Jessie).
> >=20
> > If I connect the ASUS motherboard with a MacBook Pro (Thunderbolt 2,=20
> > device ID 156c), I can see that the thunderbolt-icm driver is loaded=20
> > and that the thunderbolt-software-daemon is well started. But the=20
> > Ethernet interface is not created.
> >=20
> > I have attached to this email the syslog file. There is the logs from=
=20
> > both the kernel and the daemon inside. Note that the daemon logs are=20
> > everything but clear about what could be the issue. Maybe I missed=20
> > some kind of configuration ? But I failed to find any valuable=20
> > information about configuring the driver and/or the daemon in the vario=
us documentation files.
> >=20
> > Please, can you provide some guidance ? I'd really like to test your=20
> > patch series.
>=20
> First, thank you very much for willing to test it.
> Thunderbolt Networking support was added during Falcon Ridge, in the late=
st FR images.
> Do you know which Thunderbolt image version you have on your system?
> Currently I submitted only Thunderbolt Networking feature in Linux, and w=
e plan to add
> more features like reading the image version and updating the image.
> If you don't know the image version, the only thing I can suggest is to l=
oad windows, install thunderbolt SW
> and check in the Thunderbolt application the image version.
> To know if image update is needed, you can check - https://thunderbolttec=
hnology.net/updates

Hi Amir,

=46rom the Windows Thunderbolt software, I can read 13.00 for the firmware
version. And from https://thunderbolttechnology.net/updates, I can see
that there is no update available for my ASUS motherboard.

Am I good to go ?

BTW, it is quite a shame that the Thunderbolt firmware version can't be
read from Linux.

Simon

--nhAUiXSLan16V5i8
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iEYEARECAAYFAlgq6ogACgkQgtp0PDeOcDqw1ACeIw9i8KVjDMJpzw3n/WpjWq1t
HhkAnAoPqer0QCbfGHSpQz2u7tvLZfIt
=0iBw
-----END PGP SIGNATURE-----

--nhAUiXSLan16V5i8--
