From: Sebastian Reichel <sre@kernel.org>
Subject: Re: wl1251 & mac address & calibration data
Date: Thu, 24 Nov 2016 17:08:30 +0100
Message-ID: <20161124160830.kdpbonsz3l26uuo5@earth>
References: <201611111820.52072@pali>
 <201611221805.13606@pali>
 <20161123222335.GA4788@amd>
 <201611232339.59411@pali>
 <20161124075104.GA26721@amd>
 <20161124083329.GB13735@pali>
 <20161124151317.34yoza3dzuh46oa4@earth>
 <20161124152045.GK13735@pali>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
        protocol="application/pgp-signature"; boundary="jjlcoj7vag3ab5aq"
Cc: Pavel Machek <pavel@ucw.cz>,
        Michal Kazior <michal.kazior@tieto.com>,
        Kalle Valo <kvalo@codeaurora.org>,
        Ivaylo Dimitrov <ivo.g.dimitrov.75@gmail.com>,
        Aaro Koskinen <aaro.koskinen@iki.fi>,
        Tony Lindgren <tony@atomide.com>,
        linux-wireless <linux-wireless@vger.kernel.org>,
        Network Development <netdev@vger.kernel.org>,
        linux-kernel@vger.kernel.org
To: Pali =?iso-8859-1?Q?Roh=E1r?= <pali.rohar@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20161124152045.GK13735@pali>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--jjlcoj7vag3ab5aq
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi,

On Thu, Nov 24, 2016 at 04:20:45PM +0100, Pali Roh=C3=A1r wrote:
> On Thursday 24 November 2016 16:13:17 Sebastian Reichel wrote:
> > On Thu, Nov 24, 2016 at 09:33:29AM +0100, Pali Roh=C3=A1r wrote:
> > > On Thursday 24 November 2016 08:51:04 Pavel Machek wrote:
> > > > > > "ifconfig hw ether XX" normally sets the address. I guess that's
> > > > > > ioctl?
> > > > >=20
> > > > > This sets temporary address and it is ioctl. IIRC same as what et=
htool=20
> > > > > uses. (ifconfig is already deprecated).
> > > > >=20
> > > > > > And I guess we should use similar mechanism for permanent
> > > > > > address.
> > > > >=20
> > > > > I'm not sure here... Above ioctl =E2=86=91=E2=86=91=E2=86=91 is f=
or changing temporary mac=20
> > > > > address. But here we do not want to change permanent mac address.=
 We=20
> > > > > want to tell kernel driver current permanent mac address which is
> > > > > stored
> > > >=20
> > > > Well... I'd still use similar mechanism :-).
> > >=20
> > > Thats problematic, because in time when wlan0 interface is registered
> > > into system and visible in ifconfig output it already needs to have
> > > permanent mac address assigned.
> > >=20
> > > We should assign permanent mac address before wlan0 of wl1251 is
> > > registered into system.
> >=20
> > You can just add the MAC address to the NVS data, which is also
> > required for the device initialization.
>=20
> NVS data file has fixed size, there is IIRC no place for it.
>=20
> But one of my suggestion was to use another request_firmware for MAC
> address. So this is similar to what you are proposing, as NVS data are
> loaded by request_firmware too...

Just append it to NVS data and modify the size check accordingly?

> > I wonder if those information could be put into DT. Iirc some
> > network devices get their MAC address from DT. Maybe we can add
> > all NVS info to DT? How much data is it?
>=20
> Proprietary, signed and closed bootloader NOLO does not support DT. So
> for booting you need to append DTS file to kernel image.

Yeah, so NOLO without U-Boot will depend on userspace to fixup DT.

> U-Boot is optional and can be used as intermediate bootloader between
> NOLO and kernel. But still it has problems with reading from nand, so
> cannot read NVS data nor MAC address.

It may in the future?

> > Userspace application can add all those information to the DT
> > using a DT overlay. Also the u-boot could parse and add it at
> > some point in the future.
>=20
> In case when wl1251 is statically linked into kernel image, it is loaded
> and initialized before even userspace applications starts.
>
> So no... adding NVS data or MAC address into DT or DT overlay is not a
> solution.

Actually with data loaded from DT you *can* load data quite early in
the boot process, while your suggestions always require userspace.
So you argument against yourself?

-- Sebastian

--jjlcoj7vag3ab5aq
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAABCgAdFiEE72YNB0Y/i3JqeVQT2O7X88g7+poFAlg3EHsACgkQ2O7X88g7
+prpehAApmI//6ysva46Ws8YLd7Tf7H6XAVGqu6lDvixTpp1Q7QRkga31VRfiwZz
RqNw8MxD/PnHLBBlawTksLuzt1NzkNCpuUxxdsNehMEOkoFTpGjBhbw1WCuVI+nq
/h2zbQCSnmXzVwW7oqijQ8cXz2IHlG1G7VtpywbJQOWvkc/fN+J8xQ+xh+hFLaGY
VF8FcakjLL7VPC6k4hNheJT4ICZyZnQ+2ovFXE4QzwlquWkViIkGP8z41aLOq3yn
x5/WwTTf0F9LhebL61PsWgAH9paV7eoDDqgoKKW3K/pY8yxN3btGVOUVZNVkoo7/
NM5p5syABzNrrDBYyP+JZNRftJ/Wlv/hyag0yGztVtnLeLPbkEA6aEkOAQuF6kJR
NlCdoZ/Z+1I6f81dvNlNZ3tylFTZ2g17tJ4BgOvNxWJXL5YnxisOB+lKncz4OmZj
u9qZpmYqgudftIUFaLRfJyMdlwIMPW04DVAS7VT1OgwKg7h27reN9xjOvD9NZ52K
MTwR5HBHDDeU3MufMW6fn18sLXb0AQ2HrjvmwKz0tCHMiql8V1V+JTZ0W/PTydLv
AA5MyHAB0TrX7ByX+rELnoYAnNu97WY7T1nQMO0FY9E9tzgEVlEbaV+GeJ4fIGYv
0NU9iHOuHRJu0c7DObUCLnE5WwN/JhCxgcljNokcZEnuWvMRmqc=
=tLzj
-----END PGP SIGNATURE-----

--jjlcoj7vag3ab5aq--
