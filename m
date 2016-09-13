From: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [RFC 02/11] Add RoCE driver framework
Date: Tue, 13 Sep 2016 09:38:06 +0300
Message-ID: <20160913063806.GP8812@leon.nu>
References: <1473696465-27986-1-git-send-email-Ram.Amrani@qlogic.com>
 <1473696465-27986-3-git-send-email-Ram.Amrani@qlogic.com>
 <516b98c7-477a-4890-0d92-529dc32f2c4e@mellanox.com>
 <CY4PR11MB1720F9B74BBF82D0779FAC8F97FF0@CY4PR11MB1720.namprd11.prod.outlook.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
        protocol="application/pgp-signature"; boundary="CUrluEZVXmx7ezWQ"
Cc: Mark Bloch <markb-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
        Ram Amrani <Ram.Amrani-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org>,
        "dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org" <dledford-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
        David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        Ariel Elior <Ariel.Elior-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org>,
        Michal Kalderon <Michal.Kalderon-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org>,
        Rajesh Borundia <rajesh.borundia-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org>,
        "linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Yuval Mintz <Yuval.Mintz-h88ZbnxC6KDQT0dZR+AlfA@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <CY4PR11MB1720F9B74BBF82D0779FAC8F97FF0-JNf6+SjKdlG0ooKL/ADlEpPPoyLQLiKMvxpqHgZTriW3zl9H0oFU5g@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--CUrluEZVXmx7ezWQ
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Mon, Sep 12, 2016 at 07:17:35PM +0000, Yuval Mintz wrote:
> >> +uint debug;
> >> +module_param(debug, uint, 0);
> >> +MODULE_PARM_DESC(debug, "Default debug msglevel");
>
> >Why are you adding this as a module parameter?
>
> I believe this is mostly to follow same line as qede which also defines
> 'debug' module parameter for allowing easy user control of debug
> prints [& specifically for probe prints, which can't be controlled
> otherwise].

Can you give us an example where dynamic debug and tracing infrastructures
are not enough?

AFAIK, most of these debug module parameters are legacy copy/paste
code which is useless in real life scenarios.

Thanks


>      --
> To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
> the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

--CUrluEZVXmx7ezWQ
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1

iQIcBAEBAgAGBQJX157OAAoJEORje4g2clinZF4P/09+aMYlB2bG4cDhVZSBB7OW
u6aR5r5sKflv0TGF2L+X9fSmDf7jYABHPifYXheigy3Zg2zWbFLAf9s1tbPzeQql
N9Dzlw1hnZjL9OTB0gVKblkOQ89sPMeJTllemkLTLpEzJcYallnBfDCyXQU3vAxb
Y6PXdQViqWvxKumr4DIst1Zj+6Uawi3DdxdO0CR4Km8Gzlcooc+Kh8zmR0jCRSpP
xtYp+BodGtp7UQhYGUFYt2Ks/QfSFQ4N0Vd89oyaOLo5ri6VIQpJkbnXQxev5wU0
xWLBFD7l0YRtHE4cPlXoOHw7vyws44Area7uGH8WFh6hLEMuGvE9IlwjDBXHGFb9
YQN41Hhl6ua8eerI5tJ/ctAOKL9G3Ddcw0f4QBp+RQsgGDbPByAbvjPmgAOvuF7D
maSWtWFsS2UsP98xxxJXCxnQ/h6dmDdYvsvYHNgpmERvQwSr09F5ztbB9BRL6DdV
eSesFmRFtHIsCUvxYHvg3iZfdjCNoY15yx2WePAXRWVj7W2DNsJYoUiIZP8Zq4xN
rvU1lM9aabz5hEGA6Z8ME9v1rA+Dv8oBOTQWnbKYUEoR7JOiCaAfz8GielnVUPgR
P3SCZZAOeSAFzrLy5toKggKy67lHhNJxsKkHAp3IYFgzOPvI/tsOEskUOTCUUaLZ
vSS9tmxSnbUBmIkU+KkC
=2ENN
-----END PGP SIGNATURE-----

--CUrluEZVXmx7ezWQ--
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
