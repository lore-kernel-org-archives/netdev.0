From: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH rdma-next 08/19] RDMA/core: Expose translation from
 device name to ib_device
Date: Thu, 22 Jun 2017 08:31:25 +0300
Message-ID: <20170622053125.GK1248@mtr-leonro.local>
References: <20170621060528.3752-1-leon@kernel.org>
 <20170621060528.3752-9-leon@kernel.org>
 <20170621160748.GA10200@obsidianresearch.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="gBYU9MM4gf8jKg2V"
Cc: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Chien Tin Tung <chien.tin.tung-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        Steve Wise <swise-7bPotxP6k4+P2YhJcF5u+vpXobYPEAuW@public.gmane.org>,
        Stephen Hemminger <stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org>,
        Jiri Pirko <jiri-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Ariel Almog <ariela-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Linux Netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20170621160748.GA10200-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--gBYU9MM4gf8jKg2V
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Wed, Jun 21, 2017 at 10:07:48AM -0600, Jason Gunthorpe wrote:
> On Wed, Jun 21, 2017 at 09:05:17AM +0300, Leon Romanovsky wrote:
> > From: Leon Romanovsky <leonro-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
> >
> > Provide ability to convert from device name to ib_device for the
> > IB/core users.
>
> FWIW, as a general comment, we really need to start using some kind of
> device index like netdev does instead of the name. I'd like the see
> the new netlink interface be index based.

I can do it, but it won't be full solution as I would like to have.

At this stage, IB doesn't support namespaces yet and to implement them
is a little bit overkill for rdmatool.

>
> As we saw in a past discussion there is a desire to have stable device
> naming, which means renaming...

If I recall correctly, after your proposal the participants disappeared :).

>
> Jason

--gBYU9MM4gf8jKg2V
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkhr/r4Op1/04yqaB5GN7iDZyWKcFAllLViwACgkQ5GN7iDZy
WKdPdhAAkyTEVfUS+LqhK001A6g2TzxLCp9Z9Ypss2GjWIFGuBXbyJeIukPO/C7N
196r0EHZnaVF4keNbageS7EC15anYp8ek1WgX5ZPTOpXKNC0kOREx8CbgV0PCogE
8wkpKSfflDgh5POqT+Q0MlSRL5K9dJl2TW9j8aMFKp7p6y4FyE/uDUgzxFo9WpkO
4BnjMr1SuCCxPWmmzaEvvtsNAcSFCPAaJscZAVj5z20+iBBo37RY8UEK73kFZuWq
ZVeDf1ZJWVzW4DOaLMh09VfIMFHDmOLsL/HJqr3OtpmR2FdkRsgzvHQG2zusHdV+
1FvvXguMaZGmPF3icBj6dGYBFGY/MJvcloQYUvt+XROswFmUXzmVcQ3+YeYa75Nu
OnCWG75w+vlBAv9h8wu2sETbwUvW3OfpKS8djH4vTUkY2rhYslL7whUCScHL8ZwJ
SaH6S8L3gvmjCKUoitezmZzF9o4EcfX5FWavO5+f+8dK2bNvD1Cy+DdA2JLCT3Gx
Jy85VLqu6kgU+3Ji9GQRnjdKdVXE7upaAxODHTS6LmKNZwsyY84SmBInpAzwD6nC
aPyAhYYkpR+0Mv0RbDIAU3SrTCI3purt7aQHy61blEcBlf4I4h/ueN4C5DvZ+k4a
BJStugwsXwtpieoKUcZ5qfTse267HFi3pzZWwWUBxDwK/M7J3EA=
=Lyak
-----END PGP SIGNATURE-----

--gBYU9MM4gf8jKg2V--
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
