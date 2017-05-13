From: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: [PATCH V2 net 1/1] smc: switch to usage of
 IB_PD_UNSAFE_GLOBAL_RKEY
Date: Sat, 13 May 2017 14:29:48 +0300
Message-ID: <20170513112948.GK3616@mtr-leonro.local>
References: <20170512170952.39863-1-ubraun@linux.vnet.ibm.com>
 <20170512170952.39863-2-ubraun@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="XjbSsFHOHxvQpKib"
Cc: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, hch-jcswGhMUV9g@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-s390-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        jwi-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org, schwidefsky-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org,
        heiko.carstens-tA70FqPdS9bQT0dZR+AlfA@public.gmane.org, raspl-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org
To: Ursula Braun <ubraun-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20170512170952.39863-2-ubraun-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--XjbSsFHOHxvQpKib
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On Fri, May 12, 2017 at 07:09:52PM +0200, Ursula Braun wrote:
> This patch makes users aware of the current security implications
> when using smc.
>
> The final fix to resolve the reported security issue is worked on;
> respective patches will follow as soon as possible.
>
> Signed-off-by: Ursula Braun <ubraun-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>

I'm glad that you moved to use IB_PD_UNSAFE_GLOBAL_RKEY, so the users
will see the warning in their dmesg log.

However can you please update your commit log? There is need to add
description of security issue (access to whole physical memory), clear
message that doesn't fix anything and remove mentioning unpredictable
future (... as soon as possible ...).

Thanks

--XjbSsFHOHxvQpKib
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkhr/r4Op1/04yqaB5GN7iDZyWKcFAlkW7iwACgkQ5GN7iDZy
WKe2rQ//cIlCvj5MBS1YkDDW9lOrSbJQ3bGHkq0wo26wIykD8d0vgSaiTVuLpRUg
NEqi/VZbakNzAhbB5zLmwiRp1qEv/JzjMW6CMIcZy7k+nFRBMSXir4NQWJXeQdwn
7amWIF1au5JhxutV/MpGpN3xqyGTN9AOkZOXRJml2NThh0yRYC4jrfDb2VhElZgq
Cu/yFslaLlw/Wu47tfU0gI8EAFC69lnCX2l4Z2aPwab/3fAGGCLUxBCU9kHlGm/8
AMftKF3Fets1IxYIC7K1UJM44nKH+v1zPDpEWmpd5abp50+1hnAEGCJOtNDz0Juk
9IHvv0J4GJxGY8Acd7lNyOugQRPPloh4CLf3gexEI/3+0liW/K2lPnyDIJYPNn38
3ub+JGZFrrQR79Sq+fj77yWpzsP5IDEgd+AEy4QoO4v0NTOQ2LrbIVic25lxFq5w
R3Ubwarzj8BXHac+oqqe9vGzbT+GVrHEr+TOuQUVqIDIJ9auQRhQJ9irhyM6+IGG
P5p3MhFxiLFdzgaAMEQwE/8V/lY9mgBBUOzJJqafhmvh643tJ1/Gb651SUFXS1Za
ulz6Mzi7qPumbBJMMvuqzkwVBSPJDR74D2r4hAuX+RSSWiravK0pmNyfXFugU+ZM
lC4aa42QtEDt5cfg7NoZH/CZ6mtygXi2fKxxtJbjFtGZr5w9kbQ=
=GALp
-----END PGP SIGNATURE-----

--XjbSsFHOHxvQpKib--
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
