From: Paul Burton <paul.burton@imgtec.com>
Subject: Re: [PATCH] net: stmmac: Meet alignment requirements for DMA
Date: Tue, 26 Sep 2017 21:30:56 -0700
Message-ID: <2520219.WSsBr6LeCR@np-p-burton>
References: <71740323.RRBhnhefTi@np-p-burton> <1752163.uYYNevmZpH@np-p-burton> <20170926.195244.506518182147628099.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="nextPart3088073.UpTNVJzPrf";
        micalg=pgp-sha256; protocol="application/pgp-signature"
Cc: <matt.redfearn@imgtec.com>, <netdev@vger.kernel.org>,
        <alexandre.torgue@st.com>, <peppe.cavallaro@st.com>,
        <linux-kernel@vger.kernel.org>, <linux-mips@linux-mips.org>,
        <james.hogan@imgtec.com>
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170926.195244.506518182147628099.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--nextPart3088073.UpTNVJzPrf
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="us-ascii"

Hi David,

On Tuesday, 26 September 2017 19:52:44 PDT David Miller wrote:
> From: Paul Burton <paul.burton@imgtec.com>
> Date: Tue, 26 Sep 2017 14:30:33 -0700
> 
> > I'd suggest that at a minimum if you're unwilling to obey the API as
> > described in Documentation/DMA-API.txt then it would be beneficial
> > if you could propose a change to it such that it works for you, and
> > perhaps we can extend the API & its documentation to allow your
> > usage whilst also allowing us to catch broken uses.
> 
> The networking driver code works fine as is.
> 
> I also didn't write that ill-advised documentation in the DMA docs,
> nor the non-merged new MIPS assertion.
> 
> So I'm trying to figure out on what basis I am required to do
> anything.
> 
> Thank you.

Nobody said you wrote the documentation, but you do maintain code which 
disobeys the documented DMA API & now you're being an ass about it 
unnecessarily.

Nobody said that you are required to do anything, I suggested that it would be 
beneficial if you were to suggest a change to the documented DMA API such that 
it allows your usage where it currently does not. If you don't want to have 
any input into that, and you actually think that your current approach of 
ignoring the documented API is the best path forwards, then we're probably 
done here & I'll be making a note to avoid yourself & anything under net/ to 
whatever extent is possible...

Thanks,
    Paul
--nextPart3088073.UpTNVJzPrf
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part.
Content-Transfer-Encoding: 7Bit

-----BEGIN PGP SIGNATURE-----

iQIzBAABCAAdFiEELIGR03D5+Fg+69wPgiDZ+mk8HGUFAlnLKYAACgkQgiDZ+mk8
HGVJyxAAnRY6g4+bYlyRldy6IOLa/u30RVY+Cp+SEm8FU+SL9DWSTIlLwvo5Yeyy
1lPTtdkL0ZSNj8jB4sgaP6JscdC8+FpxXsS4vqy1K2j/XSoZjAWVAZrN7GkOZH2w
wM5AbjzcBOIkd2cWkLG4O22qkbkOolfbV1XSUros7fKZXeuHfatGs7sutRolD7iy
/KgEmF24RCYeMxp/XtolnSQcNfDWzfaNxdtm8To1j6srJ5HMTAS7goQ9sNXgQ32S
tzzHUTGXimKJdwQw3DfO4mavyN9zeW7CIvsdRtW3cQn4bxfxrW/9UUpR3ow8urav
lYrgXQa7kCCIuXX4vNK7qeYs/7V+LtjAzEp0p7NX3b5GOHu0CZxnsDQZ9u2Jf32F
3YicmJSVOB2Q/AC4RmWZ4agdHWKOU8TiuFtzItqx7GjimQG8Uaj5BjjeqRJ/CFbu
UzeLa8wVBShjAF1CmgNwsLKMle/kQpzBjxgFWl8rtDBAVTME+yH54SIAyXRDeqlX
3H/3UhzVc65lFGAJ/bA+GVzGUhfQRrRgwKhIefUY8P6hEq+MP//ZXDZuElwTSmvY
n3CnW86H8EjwL37qKgcd6hSYRTMqiMEWn/SD6ykbcYprG+IEybTv/GAymXGo1+cR
EDsJHGll7Qc0IcCNc1Y+DIH3aoqIabqILlwvX9trH1zUoAX816M=
=vqEP
-----END PGP SIGNATURE-----

--nextPart3088073.UpTNVJzPrf--
