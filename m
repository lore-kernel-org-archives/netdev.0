From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [PATCH] e1000: changed some expensive calls of udelay to
 usleep_range
Date: Tue, 22 Aug 2017 17:30:08 -0700
Message-ID: <1503448208.43048.12.camel@intel.com>
References: <1503435747-29639-1-git-send-email-matthew.tan_1@nxp.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha256";
        protocol="application/pgp-signature"; boundary="=-g6vWATLXlGAkYWdykhYA"
Cc: michael.kardonik@nxp.com, shannon.nelson@intel.com,
        carolyn.wyborny@intel.com, donald.c.skidmore@intel.com,
        bruce.w.allan@intel.com, john.ronciak@intel.com,
        mitch.a.williams@intel.com, intel-wired-lan@lists.osuosl.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
To: nxf23276 <matthew.tan_1@nxp.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1503435747-29639-1-git-send-email-matthew.tan_1@nxp.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-g6vWATLXlGAkYWdykhYA
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2017-08-22 at 16:02 -0500, nxf23276 wrote:
>     Calls to udelay are not preemtable by userspace so userspace
>     applications experience a large (~200us) latency when running on
> core
>     0. Instead usleep_range can be used to be more friendly to
> userspace
>     since it is preemtable. This is due to udelay using busy-wait
> loops
>     while usleep_rang uses hrtimers instead. It is recommended to use
>     udelay when the delay is <10us since at that precision overhead
> of
>     usleep_range hrtimer setup causes issues. However, the replaced
> calls
>     are for 50us and 100us so this should not be not an issue.
>=20
> Signed-off-by: nxf23276 <matthew.tan_1@nxp.com>
> ---
>  drivers/net/ethernet/intel/e1000e/phy.c | 8 ++++----
>  1 file changed, 4 insertions(+), 4 deletions(-)

First of all, your name is nxf23276?  Really??

Second, you titled your patch that you were makeding changes to e1000
driver, yet you are asking to modify e1000e.  Just based on these 2
needed changes, I am dropping your patch.
--=-g6vWATLXlGAkYWdykhYA
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----

iQIzBAABCAAdFiEEiTyZWz+nnTrOJ1LZ5W/vlVpL7c4FAlmczJAACgkQ5W/vlVpL
7c5aaw//YquyfqsrvEmb2folV/3TxOvUXR9UvGKz3ay74jefMWxG9ACjhQzD0cw1
YnshGFlU9y+/BObFU9BYGY4MgAf3972CuL4u6QJHglUUaaQevPUV/nMnrYxF3Oau
TJH+nWt7b44kE2vVrl3sPJOpU+gp1JUBE/WxvZX+CtrL+UE1PExRO+j/vdQpwB8g
7Y2vWxl3+C5cxm+DJ/EbN+3pIQ+EkVe0uTggeyt/hW4zIqVfOgF8tct7P8d3pPD/
6Kjo/3Pl1Mqm33x1FnoK7mq4dD5pVCt0kKbwU1cFC1tobMZz3E0xdEpOTAVe41K9
y/N8/neK6PrSGT8Vn0HsRTQdocWNOQOyxSC0kx1s5TEKRXpVcJnIX4czeNZ0zZwL
9bVvCKpz5h+G73yHHYW3txXioj013Xy5r3esVRXuZEnS/5SMHcITL8m1aakgCT9h
c7V/O63uZKuDS8I266Tf5zyBmAAtTRji+RTs2XrpRlqL5eaP3Ug0drbFDCq4aas/
riMfNvlP+ohCWsu9U1Cyp78t6hISJYohbhHIAnNZTAQkRO/Neivdpbgmx8OZmNia
C0fk1F7awWio3Fgjph/3T99CwmYuddy3mWaT+tNe3AxRnT8Het2kLgVxuIjnf3yW
nqSIFGIgba/udLJYo5Sdzy8FJC4skwukbo+UAnlJl3BPVb0uvGA=
=YrM4
-----END PGP SIGNATURE-----

--=-g6vWATLXlGAkYWdykhYA--
