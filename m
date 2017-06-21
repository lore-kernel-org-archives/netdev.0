From: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH rdma-next 08/19] RDMA/core: Expose translation from
 device name to ib_device
Date: Wed, 21 Jun 2017 18:00:28 +0300
Message-ID: <20170621150028.GH1248@mtr-leonro.local>
References: <20170621060528.3752-1-leon@kernel.org>
 <20170621060528.3752-9-leon@kernel.org>
 <022401d2ea97$fe0ecdb0$fa2c6910$@opengridcomputing.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="r5lq+205vWdkqwtk"
Cc: 'Doug Ledford' <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        'Chien Tin Tung' <chien.tin.tung-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        'Stephen Hemminger' <stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org>,
        'Jiri Pirko' <jiri-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        'Ariel Almog' <ariela-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        'Linux Netdev' <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Steve Wise <swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <022401d2ea97$fe0ecdb0$fa2c6910$@opengridcomputing.com>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--r5lq+205vWdkqwtk
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Wed, Jun 21, 2017 at 09:09:27AM -0500, Steve Wise wrote:
> > From: Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
> >
> > Provide ability to convert from device name to ib_device for the
> > IB/core users.
> >
> > Signed-off-by: Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
> > ---
> >  drivers/infiniband/core/core_priv.h | 1 +
> >  drivers/infiniband/core/device.c    | 3 +--
> >  2 files changed, 2 insertions(+), 2 deletions(-)
> >
> > diff --git a/drivers/infiniband/core/core_priv.h
> > b/drivers/infiniband/core/core_priv.h
> > index 4a150c4be175..049ccbfca988 100644
> > --- a/drivers/infiniband/core/core_priv.h
> > +++ b/drivers/infiniband/core/core_priv.h
> > @@ -184,4 +184,5 @@ int ib_nl_handle_set_timeout(struct sk_buff *skb,
> >  int ib_nl_handle_ip_res_resp(struct sk_buff *skb,
> >  			     struct netlink_callback *cb);
> >
> > +struct ib_device *__ib_device_get_by_name(const char *name);
> >  #endif /* _CORE_PRIV_H */
> > diff --git a/drivers/infiniband/core/device.c
> b/drivers/infiniband/core/device.c
> > index 7a799fc90348..4ec1b24258de 100644
> > --- a/drivers/infiniband/core/device.c
> > +++ b/drivers/infiniband/core/device.c
> > @@ -124,7 +124,7 @@ static int ib_device_check_mandatory(struct ib_device
> > *device)
> >  	return 0;
> >  }
> >
> > -static struct ib_device *__ib_device_get_by_name(const char *name)
> > +struct ib_device *__ib_device_get_by_name(const char *name)
> >  {
> >  	struct ib_device *device;
> >
> >
>
> Nit: Why is this function prefixed with __?   Perhaps now it should just be
> ib_device_get_by_name()?

The access to this function should be protected by device_mutex and
the convention is to prefix functions with "_" to mark that it needs
to handle lock.

>
>
> Reviewed-by: Steve Wise <swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org>
>
>

--r5lq+205vWdkqwtk
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkhr/r4Op1/04yqaB5GN7iDZyWKcFAllKigsACgkQ5GN7iDZy
WKeZrg/+O8Lq+tXTF9xSYcmWZ3z/3gbeGCUy+CrRnoWQLhWDt1CilocTlPHFeN3U
7Fc4zMecYxgia6hlfEgRuTPuLi/9AIfsDY4mSpxJOgVYJTheKJuo6WRviBrcUKPH
uUDxt1O72znSGWv8KB0aK2025BwHlF0ad/D9jkAbjV/kgCsfelXXJyDC9Rv4NfVD
G+Vz0DlrxcStEuQw000BcTUJUDlEkz7VjvQ2rJW8T5nhcBHNU2R7RauTFeZSo+y1
XE5AU//oWSfKFPS2Ym4ymCzV0p3HKaLOTrKA2k2M9l6FgzmWtgnkT5iwlG3IOZxK
0vG1TrWpcv3LulVC1RcjlXgxmiDPZ7UAQP5yenM5gzK5WPiXjcCpgZWhQLusLY9b
jPDmbN/xDX6D4vHpericcYsMBtyRQzJOuvzsumLtaTTmTEXQK7AmNT4o4pp2nTcF
SpLXw4wFePle5nI4P4og1SIbn9YcqtP0jVIgffU40g2bCCevPVqwQtyMCxmw6X4U
3gX1D+G802ugl8lT6vwG0Peh+t++BnDkeEOz1Am+93ZBNs0xJPd0hwsJWYfXH33w
1an1RQEisI81qgxW5e6y7WeagB0v5CCYAIrmDNPUJ0YajrNjqekrLu3Jxhk22vPE
A36GBrNwpq+l9neaX0UYAO8gBVNIEzWQovBUCCU5r2QYTd62WhY=
=0i7B
-----END PGP SIGNATURE-----

--r5lq+205vWdkqwtk--
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
