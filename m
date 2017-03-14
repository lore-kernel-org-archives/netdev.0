From: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH v4] {net,IB}/{rxe,usnic}: Utilize generic mac to eui32
 function
Date: Tue, 14 Mar 2017 19:58:43 +0200
Message-ID: <20170314175843.GY2079@mtr-leonro.local>
References: <1489500117-7937-1-git-send-email-yuval.shaia@oracle.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="acOuGx3oQeOcSZJu"
Cc: benve-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org, dgoodell-FYB4Gu1CFyUAvxtiuMwx3w@public.gmane.org, dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
        sean.hefty-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, hal.rosenstock-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org, monis-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org,
        davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Yuval Shaia <yuval.shaia-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <1489500117-7937-1-git-send-email-yuval.shaia-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--acOuGx3oQeOcSZJu
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Tue, Mar 14, 2017 at 04:01:57PM +0200, Yuval Shaia wrote:
> This logic seems to be duplicated in (at least) three separate files.
> Move it to one place so code can be re-use.
>
> Signed-off-by: Yuval Shaia <yuval.shaia-QHcLZuEGTsvQT0dZR+AlfA@public.gmane.org>
> ---
> v0 -> v1:
> 	* Add missing #include
> 	* Rename to genaddrconf_ifid_eui48
> v1 -> v2:
> 	* Reset eui[0] to default if dev_id is used
> v2 -> v3:
> 	* Add helper function to avoid re-setting eui[0] to default if
> 	  dev_id is used
> v3 -> v4:
> 	* Remove RXE wrappers
> 	* Remove addrconf_addr_eui48_xor and do the eui[0] ^= 2 in the
> 	  basic implementation
> ---
>  drivers/infiniband/hw/usnic/usnic_common_util.h | 11 +++-------
>  drivers/infiniband/sw/rxe/rxe.c                 |  4 +++-
>  drivers/infiniband/sw/rxe/rxe_loc.h             |  2 --
>  drivers/infiniband/sw/rxe/rxe_net.c             | 28 -------------------------
>  drivers/infiniband/sw/rxe/rxe_verbs.c           |  4 +++-
>  include/net/addrconf.h                          | 22 +++++++++++++++----
>  6 files changed, 27 insertions(+), 44 deletions(-)
>

Thanks, Yuval.
Reviewed-by: Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>

--acOuGx3oQeOcSZJu
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkhr/r4Op1/04yqaB5GN7iDZyWKcFAljIL1MACgkQ5GN7iDZy
WKeQNQ/+MPxnq3KvG58PhmtDunv3a1TJrmbHQmhMMOFooOn5cnM7vj0OYxP+oEnz
jx/+bJ7qMpztaAfF5J4g28AzNbNwV6cRKXxur3eDnXNGMJ1bQrghB5F9DCr9tHzP
PBEDWfBMfGhDwhFjUBS63yuaoSL81JtfTwOefJ6YVcT/IJ9zyVIDoKRy0repPJi3
AUGICUUvkZlUhqCcnvY9AfWcq5pP9pK6HFT56RglbVjyswCZsnF+fJQH58TzykyL
phifG7v3iF2wMLdZG4j2F3QydhwqXXVekgRbHMl/w6wIamexROAc7a6iZ8zeuDzi
KsvTEMW4+iyHmPvbxjtg8PvJKZUuQ1v2mIO2a5B0M14uuNQDJXKCOGA5DYA2ynlU
wfwQufJDHh4lIyFRZm5jL3kB+hslIFNbofB8BhbyJEv5cg67YM9iSSQyj2aCEW+8
KU+hQr4FzlxMKzV54ixhQ/rFoxrRDCxhul4gX7fayIJVD6YwMBVn65MFFEBSFAH+
kMvFcnqvFwG7nDhLFFKsN8az372BrcH9v8+23xFiIJ2VN+c69RKHlVaQlEK1osOO
1BuaqthvdaAIPvAn+GJIQCY2IaED5Ek44bj6D6tdNc65rQWclERtzPj3x3wk5Vmq
/oIfdg4LZtCLRDZbHipwNntJPZh/MtIHdH6Wm20rzVLRx1SP71k=
=79gT
-----END PGP SIGNATURE-----

--acOuGx3oQeOcSZJu--
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
