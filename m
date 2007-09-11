From: Herbert Xu <herbert.xu@redhat.com>
Subject: Re: [PATCH resend] Fix a lock problem in generic phy code
Date: Tue, 11 Sep 2007 10:21:10 +0800
Message-ID: <20070911022110.GC1544@gondor.apana.org.au>
References: <E1IUf6h-0006qu-00@gondolin.me.apana.org.au> <200709102045.51063.hjk@linutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jeff@garzik.org, afleming@freescale.com
To: =?iso-8859-1?Q?Hans-J=FCrgen?= Koch <hjk@linutronix.de>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1762302AbXIKCVf@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <200709102045.51063.hjk@linutronix.de>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Sep 10, 2007 at 08:45:50PM +0200, Hans-J=FCrgen Koch wrote:
>
> > Could you please audit all instances of physdev->lock and add
> > _bh where necessary?  I can see that at least phys_stop also
> > needs the _bh.
>=20
> I think the patch does all that's necessary. At least, there're no er=
ror
> messages in the logs anymore. I didn't check if there's an error on
> unload, though.

Sorry, but you can't rely on the non-existence of lockdep
messages as a proof of correctness :)

If we're going to fix the obvious bugs here, we should fix
the subtle ones too as otherwise they'll be much harder to
notice with this patch merged.

Cheers,
--=20
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
