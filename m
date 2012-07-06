From: Jeff Kirsher <tarbal@gmail.com>
Subject: Re: Intel e1000 ethernet device, change in kernel v3.4, and jumbo
 frames setting DENIED.
Date: Thu, 05 Jul 2012 23:17:15 -0700
Message-ID: <4FF682EB.9040800@gmail.com>
References: <jjE3E-5PM-29@gated-at.bofh.it> <jjGoO-7l0-19@gated-at.bofh.it> <jt59dm$fiq$1@snarked.org>
Reply-To: jeffrey.t.kirsher@intel.com
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
 protocol="application/pgp-signature";
 boundary="------------enigF321FE6A7B97859CDB295A77"
Cc: "D. Stussy" <spam+newsgroups@bde-arc.ampr.org>,
	e1000-devel@lists.sourceforge.net, netdev@vger.kernel.org
To: "D. Stussy" <replies+newsgroups@kd6lvw.ampr.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga14.intel.com ([143.182.124.37]:8041 "EHLO mga14.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751309Ab2GFGRR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Jul 2012 02:17:17 -0400
In-Reply-To: <jt59dm$fiq$1@snarked.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is an OpenPGP/MIME signed message (RFC 2440 and 3156)
--------------enigF321FE6A7B97859CDB295A77
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable

On 07/05/2012 04:53 PM, D. Stussy wrote:
> "Henrique de Moraes Holschuh"  wrote in message
> news:jjGoO-7l0-19@gated-at.bofh.it...
> On Wed, 04 Jul 2012, D. Stussy wrote:
>> There has been some changes to the driver such that things like
>> checksum verification is offloaded from the CPU.  However, this
>> blocks the ability to set a jumbo frame.  The kernel does record an
>> error indicating that checksum offloading need be disabled fro jumbo
>> frame MTU sizes to be used.  My e1000 interfaces use the 82574L
>> chipset.
>>
>> 1)  Was this an intentional change?
>
> Yes, but I understand Intel is trying to come up with a way not to
> need it.
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> OK, found the modification.  NETIF_F_RXHASH turned on by default in a
> modification ("Receive Packet Steering support") from January 26, 2012.=

>
> Features which have no OFF setting should DEFAULT OFF and wait to be
> explicitly enabled.  The change which was inserted is stupid.
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
>
>> 2)  How do I disable that function so I can set jumbo frames with
>> "ifconfig" or "ip"?  I simply don't know what setting I need to
>> pass.
>
> ethtool can do it.  Check its manpage, it can manipulate the various NI=
C
> offload engines, as well as other parameters such as dma ring buffer
> size,
> etc.
> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
> Got it:  ethtool -K eth0 rx off
>
> However, I'd prefer to turn off hashing instead of the checksum and I
> didn't recognize a single setting which would do that.  Under "ethtool
> -N", there seem to be 8 settings, but none of the options seemed to
> disable hashing (without simultaneously dropping packets).  I still
> need help:  What is the correct setting I need to disable this?  I
> don't see a simple OFF setting.
>
> Else, this part of the patch should be reversed:
> --- a/drivers/net/ethernet/intel/e1000e/netdev.c
> +++ b/drivers/net/ethernet/intel/e1000e/netdev.c
> @@ -6136,6 +6213,7 @@ static int __devinit e1000_probe(struct pci_dev
> *pdev,
> NETIF_F_HW_VLAN_TX |
> NETIF_F_TSO |
> NETIF_F_TSO6 |
> +                NETIF_F_RXHASH |
> NETIF_F_RXCSUM |
> NETIF_F_HW_CSUM);
> --=20

Adding the more appropriate mailing lists of netdev and e1000-devel


--------------enigF321FE6A7B97859CDB295A77
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: OpenPGP digital signature
Content-Disposition: attachment; filename="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)
Comment: Using GnuPG with Mozilla - http://enigmail.mozdev.org/

iQIcBAEBCgAGBQJP9oLrAAoJEOVv75VaS+3OxRgP/12F/xD4s3E/uVlPeRz63hg9
YWlrthxLvj57IDeEFxrcRVZvPfVYHojPHxTyODiUHodJgcA13BHETK+COewUX9if
IZR8RD4ApOEd/geM2x7ScBE/x5Hataxg0qjkTwgNz/p1KbR237AxwMNy8UPixNya
osJEk+An/L6nkRcsZgtDm786i+6BM+o7B3yd7LSfv9JUu7xW+6zNobvB7ehKmtC2
GIAM6RWuxSCWGnX5h6Z314sSJSNQ7057drCWz8VYq/r8P54bpZwNhAII9oxwIiN2
06yYx2qcIdtleZc9unYOX+QxW65p/ytQmKA4UywLvss2Jtm4v9krVF9VqkTHPZSK
cS8Yb4fHQD/TYncHJibC0sXEGpgy1k2jBz8Vy4+1c04fvXIptjmh7sz8MYk5IPSt
YYtWFeSu+51zaWtJy8rsYtqypNdNH7bU7Laa0JQdbpAOpvWpXCdBLPqTkAiDuZAe
51qI0ykYRfUFS+3FOz8JRwd/gYjtjgxjJeN4Utdnq0knATnW2dQ5T6G2cgY8HMcZ
659Ox15kJL5S/+YZSk0dk5PBPtVuk1Uvx2LbuyFtxtfVfv5uNJO2Fkru7dnfDSPt
Orvu3Q2Fklai9fC4pvvGiUhSofQy4tzfQ2fyxftc/t2BrT9GKl6PcOgfOpY5+bmz
2o6eHBE0uAqKStN37/yn
=9D8I
-----END PGP SIGNATURE-----

--------------enigF321FE6A7B97859CDB295A77--
