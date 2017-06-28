From: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH iproute2 V1 3/6] rdma: Add device capability parsing
Date: Wed, 28 Jun 2017 07:16:48 +0300
Message-ID: <20170628041648.GW1248@mtr-leonro.local>
References: <20170627143920.28020-1-leon@kernel.org>
 <20170627143920.28020-4-leon@kernel.org>
 <20170627160449.58e40a9f@xeon-e3>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="0+/s3RgBAfRJTJO/"
Cc: Doug Ledford <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        Ariel Almog <ariela-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Dennis Dalessandro <dennis.dalessandro-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>,
        Jason Gunthorpe <jgunthorpe-ePGOBjL8dl3ta4EC/59zMFaTQe2KTcn/@public.gmane.org>,
        Linux RDMA <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Linux Netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Stephen Hemminger <stephen-OTpzqLSitTUnbdJkjeBofR2eb7JE58TQ@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20170627160449.58e40a9f@xeon-e3>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--0+/s3RgBAfRJTJO/
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Tue, Jun 27, 2017 at 04:04:49PM -0700, Stephen Hemminger wrote:
> On Tue, 27 Jun 2017 17:39:17 +0300
> Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org> wrote:
>
> > +static const char *dev_caps[64] = {
> > +	"RESIZE_MAX_WR",
> > +	"BAD_PKEY_CNTR",
> > +	"BAD_QKEY_CNTR",
> > +	"RAW_MULTI",
> > +	"AUTO_PATH_MIG",
> > +	"CHANGE_PHY_PORT",
> > +	"UD_AV_PORT_ENFORCE",
> > +	"CURR_QP_STATE_MOD",
> > +	"SHUTDOWN_PORT",
> > +	"INIT_TYPE",
> > +	"PORT_ACTIVE_EVENT",
> > +	"SYS_IMAGE_GUID",
> > +	"RC_RNR_NAK_GEN",
> > +	"SRQ_RESIZE",
> > +	"N_NOTIFY_CQ",
> > +	"LOCAL_DMA_LKEY",
> > +	"RESERVED",
> > +	"MEM_WINDOW",
> > +	"UD_IP_CSUM",
> > +	"UD_TSO",
> > +	"XRC",
> > +	"MEM_MGT_EXTENSIONS",
> > +	"BLOCK_MULTICAST_LOOPBACK",
> > +	"MEM_WINDOW_TYPE_2A",
> > +	"MEM_WINDOW_TYPE_2B",
> > +	"RC_IP_CSUM",
> > +	"RAW_IP_CSUM",
> > +	"CROSS_CHANNEL",
> > +	"MANAGED_FLOW_STEERING",
> > +	"SIGNATURE_HANDOVER",
> > +	"ON_DEMAND_PAGING",
> > +	"SG_GAPS_REG",
> > +	"VIRTUAL_FUNCTION",
> > +	"RAW_SCATTER_FCS",
> > +	"RDMA_NETDEV_OPA_VNIC",
> > +};
>
> Please use array initializer so that header and capabilities don't get different values.
> Are the bit values in some rdma header file?

It is enum ib_device_cap_flags copied from include/rdma/ib_verbs.h.
These enum ib_device_cap_flags and enum ib_port_cap_flags are not exposed
to the user (include/uapi/rdma/*) and I'm planning to move them there in
next cycle.

Thanks

--0+/s3RgBAfRJTJO/
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkhr/r4Op1/04yqaB5GN7iDZyWKcFAllTLbAACgkQ5GN7iDZy
WKd/yg/+JJDDPv2LVWhTRnWyaX82Bcysk5tc3uDXLYSMmOrC3nYsGWIJrLWBBCLt
MRHEiLeXAG/zLbRG47KTBoYtGkdVVjzPEOl3atCM6iIgNbakIL/jZr5UdxBtMKNp
Y0PV5Hak7hi0DGIUdql7lQebUt2cNQ4f8URK6n6bv0fxIMKPueV5X7CTsgmo4IYj
tNObR1CDWQcHsb5ad7UzcIPa0Xkgv3LBkYf4zMyaLWY1WL9LszVcwUNZW8sRRljY
MXJ4ZtGqCINL2+DH/IsWQzdUFj69/7QlmOlETOis4/rnr9fZN4Lsahu4H46M2vsO
Z09GjS4BwIv0Q0tABM5E4DQ78r2kUiaPVEmnbrZX20xq12PGxF422/hLrDc+8EOr
VoEG+rDo/uA6fOd8cbsYmg7IlQ6n8B/PXjfsCOG8vxc/Rpgdw6FmOniZr38DfOXk
UPGZG0AK0Ci13XTbkZET+DIywJ2lV4LSKHnhClSUvKMF+MAw1EeCBzada2ES2yiI
LVYtW4TH+T8k9OvkP369MRKPolejFBy3h+LnqTyjVTBJ09rbEaK+pjYvwIL7z7N/
GSMQVzKPTVdUCVlcRxjp8A36jMm4yYXQqvkz6TrBMATGJuK/73c0fAVg8PdCeZlF
4NFfF+qt0Yx2cbpEbOLKinmyr3ttYUOI9UJu2Mgp2v91npuFSjU=
=rnuf
-----END PGP SIGNATURE-----

--0+/s3RgBAfRJTJO/--
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
