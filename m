From: Leon Romanovsky <leon-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Subject: Re: net/smc and the RDMA core
Date: Thu, 4 May 2017 16:15:23 +0300
Message-ID: <20170504131523.GV22833@mtr-leonro.local>
References: <20170501163311.GA22209@lst.de>
 <d9214af6-1c6f-9f95-fc00-3e4a316b4f81@linux.vnet.ibm.com>
 <1493750358.2552.13.camel@sandisk.com>
 <1b79048f-4495-3840-e7a6-d4fa5a8dfb57@grimberg.me>
 <20170504084825.GA5399@lst.de>
 <efa9bd6d-1df9-952a-7f32-c2ee6bffcae5@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha256;
        protocol="application/pgp-signature"; boundary="PpocKf6TCvdC9BKE"
Cc: "hch-jcswGhMUV9g@public.gmane.org" <hch-jcswGhMUV9g@public.gmane.org>, Sagi Grimberg <sagi-NQWnxTmZq1alnMjI0IkVqw@public.gmane.org>,
        Bart Van Assche <Bart.VanAssche-XdAiOPVOjttBDgjK7y7TUQ@public.gmane.org>,
        "davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
        "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Ursula Braun <ubraun-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <efa9bd6d-1df9-952a-7f32-c2ee6bffcae5-23VcF4HTsmIX0ybBhKVfKdBPR1lH4CV8@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org


--PpocKf6TCvdC9BKE
Content-Type: text/plain; charset=utf-8
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Thu, May 04, 2017 at 03:08:39PM +0200, Ursula Braun wrote:
>
>
> On 05/04/2017 10:48 AM, hch-jcswGhMUV9g@public.gmane.org wrote:
> > On Thu, May 04, 2017 at 11:43:50AM +0300, Sagi Grimberg wrote:
> >> I would also suggest that you stop exposing the DMA MR for remote
> >> access (at least by default) and use a proper reg_mr operations with a
> >> limited lifetime on a properly sized buffer.
> >
> > Yes, exposing the default DMA MR is a _major_ security risk.  As soon
> > as SMC is enabled this will mean a remote system has full read/write
> > access to the local systems memory.
> >
> > There =D1=96s a reason why I removed the ib_get_dma_mr function and rep=
laced
> > it with the IB_PD_UNSAFE_GLOBAL_RKEY key that has _UNSAFE_ in the name
> > and a very long comment explaining why, and I'm really disappointed that
> > we got a driver merged that instead of asking on the relevant list on
> > why a change unexpertong a function it needed happened and instead
> > tried the hard way to keep a security vulnerarbility alive.
> >
> Thanks for pointing out these problems. We will address them.
>

Out of curiosity, when do you plan to address all this?

Thanks

--PpocKf6TCvdC9BKE
Content-Type: application/pgp-signature; name="signature.asc"

-----BEGIN PGP SIGNATURE-----

iQIzBAEBCAAdFiEEkhr/r4Op1/04yqaB5GN7iDZyWKcFAlkLKWsACgkQ5GN7iDZy
WKck+Q//R5lRchnNuvYuBr3/3y/UXLF7LRkmBjOMX6LG3DCSVgJ2fscqhihWF8f1
+puOlCtCuCEgjXR7CFbXJpL83vKqw6gru2Q4g/fzH7Bu4Cjx+ennxAzyl1EYSDqL
nCmdttezEHWD83bcmZuwznpa+ACe1ADwTxlHHpUV84M2e2B9pSZiIx712S/2ANdc
JuYOAIanrWD1tenaMsmX6QsFd4MophHy77BKTqLHKnFmA1+daeNJ95K+1TJwSVDT
gym1Oid0zVCmLJvjJzNUijaye+jonu1nFnvr4Xfio2qJlQVyCxT9CNO8iZ3TE3R2
v9G+L5JhuYb4GrZWpCY9j8uJElvRCClVt2nh+RDt0LO+ysZUJ6DpwjHQCpPU4BoK
RV0jmfWZhcgdw6jXtZsP7GH7OUuDUMGqgFpoSn7CE+uYvtu7r/SxZ04hi1aSboJw
kh1i7Exnwl0YGMTaxwP4LBF7yek9u3EDAU71bC9nzEz/9bz9XKpDe2Ph56Stm0E1
2Uv+CEOdB5/Pa9mLOylipXpddDNRi5AQTN5YxWydHP42MaTJtCzylvzGfq/FH3WX
/dvXuCn3cRsOn9pKfSMOrRoBiKR0bUnKtDY89bNrzCL8ysSYIhIqBGW/2vYITNiW
q/gv4B8c36zaxZgntPd6tsp/sk/YlEEMX5cYXa9v4pEPs14UKck=
=fe0e
-----END PGP SIGNATURE-----

--PpocKf6TCvdC9BKE--
--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
