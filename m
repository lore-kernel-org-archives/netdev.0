From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: Re: [net] Revert "e1000e: driver trying to free already-free irq"
Date: Thu, 23 Mar 2017 20:57:26 -0700
Message-ID: <1490327846.5679.24.camel@intel.com>
References: <20170324034715.72855-1-jeffrey.t.kirsher@intel.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg="pgp-sha256";
        protocol="application/pgp-signature"; boundary="=-fb+xttE9NqN1p/VBuXi6"
Cc: netdev@vger.kernel.org, nhorman@redhat.com, sassmann@redhat.com,
        jogreene@redhat.com
To: davem@davemloft.net, stable@vger.kernel.org
Return-path: <stable-owner@vger.kernel.org>
In-Reply-To: <20170324034715.72855-1-jeffrey.t.kirsher@intel.com>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


--=-fb+xttE9NqN1p/VBuXi6
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: quoted-printable

On Thu, 2017-03-23 at 20:47 -0700, Jeff Kirsher wrote:
> This reverts commit 7e54d9d063fa239c95c21548c5267f0ef419ff56.
>=20
> After additional regression testing, several users are experiencing
> kernel panics during shutdown on e1000e devices.=C2=A0=C2=A0Reverting thi=
s
> change resolves the issue.
>=20
> Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>

CC: <stable@vger.kernel.org>

Sorry, meant to queue this up for stable as well.

> ---
> =C2=A0drivers/net/ethernet/intel/e1000e/netdev.c | 2 +-
> =C2=A01 file changed, 1 insertion(+), 1 deletion(-)
>=20
> diff --git a/drivers/net/ethernet/intel/e1000e/netdev.c
> b/drivers/net/ethernet/intel/e1000e/netdev.c
> index 2175cced402f..e9af89ad039c 100644
> --- a/drivers/net/ethernet/intel/e1000e/netdev.c
> +++ b/drivers/net/ethernet/intel/e1000e/netdev.c
> @@ -6274,8 +6274,8 @@ static int e1000e_pm_freeze(struct device *dev)
> =C2=A0		/* Quiesce the device without resetting the hardware
> */
> =C2=A0		e1000e_down(adapter, false);
> =C2=A0		e1000_free_irq(adapter);
> -		e1000e_reset_interrupt_capability(adapter);
> =C2=A0	}
> +	e1000e_reset_interrupt_capability(adapter);
> =C2=A0
> =C2=A0	/* Allow time for pending master requests to run */
> =C2=A0	e1000e_disable_pcie_master(&adapter->hw);

--=-fb+xttE9NqN1p/VBuXi6
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part
Content-Transfer-Encoding: 7bit

-----BEGIN PGP SIGNATURE-----

iQIzBAABCAAdFiEEiTyZWz+nnTrOJ1LZ5W/vlVpL7c4FAljUmSYACgkQ5W/vlVpL
7c5TjA/+I6HFJLXFq3y5JgHeH9Jgeycp7mPp3euJ4s0XO8ktIQRr76OXGTb+ocKd
QwFXEQo4o7Bl9w+3ZQFDEcL/uIaWf6ZhWSCYMBMj7SlwV4jdGv2lMFz+cES5P0Nb
uwPzRNIqpk4b4tU6EYppu9Wt/9EltjOCPd2YVkFt/fJOmwvwmSD5mJ7dfMgn0tG4
yZoP+XByrV2ciosudrjCjnNekpxBPhj0TGucqMG9nEthFUosvNWso9tAas5Ddq48
Db1Z3UjZAlr9xgx/UXB+rH0C9vHl06sRKCVlGAVVeIQk9SzBIpiIPe1/GLnf5ZNO
v60hwwwmg7l7cnIzKSwUoTfzvpabmJNeVNgZch58+IaOuXwlGbjXOEY4YYLExS3r
zq2FrKyuRWFz8lKyH1D73jqOvh6r7BvOWLpCec2oDaIdMXhoPzcCOJkBZHScZgqw
mHQeJdEwWxsxabr5pryk8vjoVhFj4+Y1K+ygu4426LhQuGZFX638HnrL2bdmozcV
UzNBsyAse9vhIaUrcrXG4ybBcfMBqtJtVKGXjwjFy0inP9ke40J+eqTC8xC72Ah2
1Ejx2M1W0kXkn3Mh+DtEdUDVqLNPJl6eMObopS1noF27BOsm2sRKn+hB083f4wqg
4icTpMU6LY5QdMikIqkKBTapncSVT5jS82IhpZ5zZklugkyGDts=
=H6vG
-----END PGP SIGNATURE-----

--=-fb+xttE9NqN1p/VBuXi6--
