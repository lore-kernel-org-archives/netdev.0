From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [Intel-wired-lan] [net-next PATCH v2 2/6] i40e: Introduce VF
 Port Representator(VFPR) netdevs.
Date: Thu, 05 Jan 2017 13:46:11 -0800
Message-ID: <1483652771.25700.41.camel@intel.com>
References: <1483466874-2962-1-git-send-email-sridhar.samudrala@intel.com>
         <1483466874-2962-3-git-send-email-sridhar.samudrala@intel.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha512";
        protocol="application/pgp-signature"; boundary="=-4Ntf1jCaY1RR2a9Ep89c"
To: Sridhar Samudrala <sridhar.samudrala@intel.com>,
        alexander.h.duyck@intel.com, john.r.fastabend@intel.com,
        anjali.singhai@intel.com, jakub.kicinski@netronome.com,
        davem@davemloft.net, intel-wired-lan@lists.osuosl.org,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga09.intel.com ([134.134.136.24]:22240 "EHLO mga09.intel.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1752228AbdAEVqq (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 5 Jan 2017 16:46:46 -0500
In-Reply-To: <1483466874-2962-3-git-send-email-sridhar.samudrala@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-4Ntf1jCaY1RR2a9Ep89c
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Tue, 2017-01-03 at 10:07 -0800, Sridhar Samudrala wrote:
> VF Port Representator netdevs are created for each VF if the switch mode
> is set to 'switchdev'. These netdevs can be used to control and configure
> VFs from PFs namespace. They enable exposing VF statistics, configure and
> monitor link state, mtu, filters, fdb/vlan entries etc. of VFs.
> Broadcast filters are not enabled in switchdev mode.
>=20
> Sample script to create VF port representors
> # rmmod i40e; modprobe i40e
> # devlink dev eswitch set pci/0000:05:00.0 mode switchdev
> # echo 2 > /sys/class/net/enp5s0f0/device/sriov_numvfs
> # ip l show
> 297: enp5s0f0: <BROADCAST,MULTICAST> mtu 1500 qdisc noop portid
> 6805ca2e7268 state DOWN mode DEFAULT group default qlen 1000
> =C2=A0=C2=A0=C2=A0=C2=A0 link/ether 68:05:ca:2e:72:68 brd ff:ff:ff:ff:ff:=
ff
> =C2=A0=C2=A0=C2=A0=C2=A0 vf 0 MAC 00:00:00:00:00:00, spoof checking on, l=
ink-state auto,
> trust off
> =C2=A0=C2=A0=C2=A0=C2=A0 vf 1 MAC 00:00:00:00:00:00, spoof checking on, l=
ink-state auto,
> trust off
> 299: enp5s0f0-vf0: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN
> mode DEFAULT group default qlen 1000
> =C2=A0=C2=A0=C2=A0=C2=A0 link/ether 00:00:00:00:00:00 brd ff:ff:ff:ff:ff:=
ff
> 300: enp5s0f0-vf1: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN
> mode DEFAULT group default qlen 1000
> =C2=A0=C2=A0=C2=A0=C2=A0 link/ether 00:00:00:00:00:00 brd ff:ff:ff:ff:ff:=
ff
>=20
> Signed-off-by: Sridhar Samudrala <sridhar.samudrala@intel.com>
> ---
> =C2=A0drivers/net/ethernet/intel/i40e/i40e_main.c=C2=A0=C2=A0=C2=A0=C2=A0=
=C2=A0=C2=A0=C2=A0 |=C2=A0 21 ++-
> =C2=A0drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.c | 154
> ++++++++++++++++++++-
> =C2=A0drivers/net/ethernet/intel/i40e/i40e_virtchnl_pf.h |=C2=A0 14 ++
> =C2=A03 files changed, 182 insertions(+), 7 deletions(-)

This does not apply cleanly because it is based on an older version of
i40e_virtchnl_pf.c file.  It appears that i40e has been updated to use
"i40e_add_filter()" yet your patch still uses "i40e_add_mac_filter()".

We need to clarify what the "right way" is to add filters and use the
correct function.

Dropping this series and will await v3, please address the other feedback
from Or Gerlitz and Jiri Pirko as well in your updated series.
--=-4Ntf1jCaY1RR2a9Ep89c
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQIcBAABCgAGBQJYbr6jAAoJEOVv75VaS+3O36UQAJYtJRJIPNtXaTwtjw3yQa3z
wwVC5i12lOL88/R2UuSfYV0wN61la8vQwhafY1PmFnhzeUHI4Lz81K2du0R09CDY
uph8s1VxQ1OkrfXsqnW33htflYk8vULabOQu0PXNeFEo7BHOmbR71uFMqK4PVjLy
PTEmXZWIuqcAkJZ6sZgy0Sq/d+yDg9rjd7ChXeI43ailYcTpxkRCwVSrvmoo1RhL
yyMt0QUxQlGqIhyO2kPyx18EGyJHK88a3JXDpa+6AWzGTfUDttJI3ULiV5srJONG
pJhlvMvLwCkVR+d+vFPMRyG2zHZaEPY28o0SGEd/oegqBpyIbF4Ws7aSxKdQmyLw
3UMt6hXtlr8tNrXoEIAm+IYuuf32+ec9Z0g7XJjim2yOTBZVxYThE6U7bkChpJNk
0cPKafHtqmm05+2FnKDXlbT97fTLNRmShHz9260PU9Pd+U7XYIzSHYRJDYhOw9qS
XF48U50+l8H/kQQ2QfwEZWSQtBmfbStsCR/tyvVGfcMy1r+fpdXwNn6uFndJg8+R
J9B63fCkcfX7sPbVD/GVkp1F10IAVeId94yfIfqIsSOw/J26/k73aAeFNk88wngx
k8xAXAg29Py87L6KUPnrEIH8D/xDwzySqdejgCn0l5lg3pRD8K3imAdPhgjsuPfm
6ZxdRCbWb78snDZH1oNg
=LhbQ
-----END PGP SIGNATURE-----

--=-4Ntf1jCaY1RR2a9Ep89c--
