From: Sven Eckelmann <sven-KaDOiPu9UxWEi8DpZVb4nw@public.gmane.org>
Subject: Re: [PATCH 9/9] batman-adv: Use packing of 2 for all
	headers before an ethernet header
Date: Wed, 21 Nov 2012 14:51:02 +0100
Message-ID: <7016771.yWLQhgLl2P@sven-laptop.home.narfation.org>
References: <1353499919-28596-1-git-send-email-ordex@autistici.org>
 <1353499919-28596-10-git-send-email-ordex@autistici.org>
 <AE90C24D6B3A694183C094C60CF0A2F6026B70BB@saturn3.aculab.com>
Reply-To: The list for a Better Approach To Mobile Ad-hoc Networking
 <b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="nextPart11189786.PTu3lqnrKF";
 micalg="pgp-sha512"; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7Bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org,
 Marek Lindner <lindner_marek-LWAfsSFWpa4@public.gmane.org>, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: David Laight <David.Laight-JxhZ9S5GRejQT0dZR+AlfA@public.gmane.org>
Return-path: <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
In-Reply-To: <AE90C24D6B3A694183C094C60CF0A2F6026B70BB-CgBM+Bx2aUAnGFn1LkZF6NBPR1lH4CV8@public.gmane.org>
List-Unsubscribe: <https://lists.open-mesh.org/mm/options/b.a.t.m.a.n>,
 <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=unsubscribe>
List-Archive: <http://lists.open-mesh.org/pipermail/b.a.t.m.a.n/>
List-Post: <mailto:b.a.t.m.a.n-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Help: <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=help>
List-Subscribe: <https://lists.open-mesh.org/mm/listinfo/b.a.t.m.a.n>,
 <mailto:b.a.t.m.a.n-request-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org?subject=subscribe>
Errors-To: b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org
Sender: "B.A.T.M.A.N" <b.a.t.m.a.n-bounces-ZwoEplunGu2X36UT3dwllkB+6BGkLq7r@public.gmane.org>
List-Id: netdev.vger.kernel.org


--nextPart11189786.PTu3lqnrKF
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="Windows-1252"

On Wednesday 21 November 2012 13:36:54 David Laight wrote:
> > All packet headers in front of an ethernet header have to be completely
> > divisible by 2 but not by 4 to make the payload after the ethernet header
> > again 4 bytes boundary aligned.
> 
> I'm not sure that statement is correct - whether the patches are
> correct rather depends on the actual packet format(s) you are
> generating/modifying.
> 
> If you are adding data to an ethernet packet you'll need
> to add a multiple of 4 bytes in order maintain the alignment
> of the IP header (which needs to be 4 byte aligned and is
> usually 14 bytes from the start of the receive data).
> 
> This means that the data you add probably has to be 4n+2
> aligned - since I guess you are adding between the source
> MAC address and ethertype?
> If you are inserting data after the ethertype (ie after some
> protocol identifier), then your header can be 4 byte aligned
> provided it ends with the replacement ethertype (0800 or 0806
> for IP protocols).

No, it looks like this

ethernet header | batman-adv stuff | ethernet header | ip header

Kind regards,
	Sven
--nextPart11189786.PTu3lqnrKF
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.12 (GNU/Linux)

iQIcBAABCgAGBQJQrNxGAAoJEF2HCgfBJntGWZMP/1onuelI2Y3TBJBilUuSSnSP
BLtPW7GQ2u3NFt27So/SJthfEfTnv0Tt6Ie3E5jWyZIpF+PyKsI/Da+Sl95zqEvD
HvpVzJsZq5hPf02J6W6CZDB1i6fS/8rL5yWD0uh1pEdwcRhiL3Zj33sHfWX01uhB
MUVuIk89h6MzpGWXDWXuiRL0yZtXKrV5wPCWV8zUq2t0mVYrgXfWRD5JDtzHeVO6
mo1RSRIpwZQXJ2K4ECmVEKGoUnA4xVhOLRQjc7gy+3VX6ug4hTIKhNGWrndUndWM
5ERJYOB1lK4Bq9bKd5oSrnpnqHze+is/aeDIVLJgxcXpLhtDYBniMpU+LZ5qNRr8
ngio+IqC7cxbtZmEg8hLijIyWodEgRdTtlZ0k7xV2l3//SSHQ7xIqkqcY1RLh6Ep
Gaz9mKJ65sBgq0pkYih2LPx2+Ycix60ARVyhFmDOAgmvMofazQvWTAVxlM1CuT47
agG385MHOtKp2fht0fHZJOtCh0mpYMZhVY5GV2cVwVZcarF6tHNoXt/Lv8hCGRBz
IMQSyR9I1X3kwkXsG/AsM3G961IA1b/GsBYHM07v4BO/z+9wMC6OdyW/dbxBYekq
pOlttqJiSuIy0loNooDRgfSfgXox64r7cJUVFaANg4JhqU3+M6jSol5hjKzP0DYt
7a6BQlTxFjWYAoC22JTB
=HCJv
-----END PGP SIGNATURE-----

--nextPart11189786.PTu3lqnrKF--
