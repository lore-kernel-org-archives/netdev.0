From: Michal Simek <monstr@monstr.eu>
Subject: Re: [PATCH 1/2] net: emaclite: Remove unnecessary code that
 enables/disables interrupts on PONG buffers
Date: Mon, 02 Dec 2013 12:20:02 +0100
Message-ID: <529C6CE2.60909@monstr.eu>
References: <f9b49a0c-0627-432d-b6c9-faeaa7c412b8@CH1EHSMHS011.ehs.local>
Reply-To: monstr@monstr.eu
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============0573134421737909683=="
Cc: netdev@vger.kernel.org, Srikanth Thokala <sthokal@xilinx.com>,
 davem@davemloft.net, linux-arm-kernel@lists.infradead.org,
 Michal Simek <michal.simek@xilinx.com>
To: Srikanth Thokala <srikanth.thokala@xilinx.com>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <f9b49a0c-0627-432d-b6c9-faeaa7c412b8@CH1EHSMHS011.ehs.local>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--===============0573134421737909683==
Content-Type: multipart/signed; micalg=pgp-sha1;
 protocol="application/pgp-signature";
 boundary="QBlf0HI7j2rgnt9d05tK9jXsm6t1f7GUX"

This is an OpenPGP/MIME signed message (RFC 4880 and 3156)
--QBlf0HI7j2rgnt9d05tK9jXsm6t1f7GUX
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: quoted-printable

On 11/28/2013 08:29 AM, Srikanth Thokala wrote:
> There are no specific interrupts for the PONG buffer on both
> transmit and receive side, same interrupt is valid for both
> buffers. So, this patch removes this code.
>=20
> Signed-off-by: Srikanth Thokala <sthokal@xilinx.com>
> ---
>  drivers/net/ethernet/xilinx/xilinx_emaclite.c | 38 -------------------=
--------
>  1 file changed, 38 deletions(-)

Reviewed-by: Michal Simek <monstr@monstr.eu>

Thanks,
Michal

--=20
Michal Simek, Ing. (M.Eng), OpenPGP -> KeyID: FE3D1F91
w: www.monstr.eu p: +42-0-721842854
Maintainer of Linux kernel - Microblaze cpu - http://www.monstr.eu/fdt/
Maintainer of Linux kernel - Xilinx Zynq ARM architecture
Microblaze U-BOOT custodian and responsible for u-boot arm zynq platform



--QBlf0HI7j2rgnt9d05tK9jXsm6t1f7GUX
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Using GnuPG with Thunderbird - http://www.enigmail.net/

iEYEARECAAYFAlKcbOIACgkQykllyylKDCH+zQCeLIwXqEbLUJfbjngJ3SGZAsYd
TJQAmgJCZCc64o7TP9b8UafwA2WIh//i
=yDL0
-----END PGP SIGNATURE-----

--QBlf0HI7j2rgnt9d05tK9jXsm6t1f7GUX--


--===============0573134421737909683==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
linux-arm-kernel mailing list
linux-arm-kernel@lists.infradead.org
http://lists.infradead.org/mailman/listinfo/linux-arm-kernel

--===============0573134421737909683==--
