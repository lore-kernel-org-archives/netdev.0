From: hiren panchasara <hiren@strugglingcoder.info>
Subject: Re: RACK not getting disabled
Date: Mon, 18 Sep 2017 14:55:22 -0700
Message-ID: <20170918215522.GE28186@strugglingcoder.info>
References: <20170918201428.GB28186@strugglingcoder.info>
 <1505769494.29839.34.camel@edumazet-glaptop3.roam.corp.google.com>
 <20170918212952.GC28186@strugglingcoder.info>
 <CAK6E8=eu+1ywBfpAM34seZDKVc-ep5HBuz9fQRuzoaX9BWqeJA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha512;
        protocol="application/pgp-signature"; boundary="vmttodhTwj0NAgWp"
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
        netdev <netdev@vger.kernel.org>
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from strugglingcoder.info ([104.236.146.68]:54770 "EHLO
        mail.strugglingcoder.info" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751341AbdIRVzT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 18 Sep 2017 17:55:19 -0400
Content-Disposition: inline
In-Reply-To: <CAK6E8=eu+1ywBfpAM34seZDKVc-ep5HBuz9fQRuzoaX9BWqeJA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--vmttodhTwj0NAgWp
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

On 09/18/17 at 02:46P, Yuchung Cheng wrote:
> On Mon, Sep 18, 2017 at 2:29 PM, hiren panchasara
> <hiren@strugglingcoder.info> wrote:
> > On 09/18/17 at 02:18P, Eric Dumazet wrote:
> >> On Mon, 2017-09-18 at 13:14 -0700, hiren panchasara wrote:
> >> > Hi all, I am trying to disable rack to see 3dupacks in action during
> >> > loss-detection but based on the pcap, I see that it's still trigger
> >> > loss-recovery on the first SACK (as if RACK is still enabled/active).
> just to be clear: 3-dupack (aka RFC3517) is still enabled with RACK
> enabled. I am experimenting a patch set to disable 3-dupack approach
> completely.

So any incoming packet undergoes both checks right now to decide whether
to mark it lost based on 3-dupacks (and eventually rfc6675) and also
rack? Any insights into how they are working together would be great.

Also whichever scheme detects loss first can kick connection into
loss-recovery, right?

Thanks for the clarification, Yuchung.

Cheers,
Hiren

--vmttodhTwj0NAgWp
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2

iQF8BAABCgBmBQJZwEDIXxSAAAAAAC4AKGlzc3Vlci1mcHJAbm90YXRpb25zLm9w
ZW5wZ3AuZmlmdGhob3JzZW1hbi5uZXRBNEUyMEZBMUQ4Nzg4RjNGMTdFNjZGMDI4
QjkyNTBFMTU2M0VERkU1AAoJEIuSUOFWPt/ldDQH/2gZAO3OxUZJBMYwBCXHrsFC
OV3u7WXq5E40qd140Jjrydmv9VnwwzkXgqEO6Inyn7Y6XjrmHEOgzQRe8SQjmRRh
aLtkpptXq8sFmE5/zi+XptlqkgmNbgnhPgJ4qjTA61TvycAk0k4Fhj9O5WJZPlCl
s4u+1iOSSgL9kc6hu/00B1Ke1RiAM8Jru8W1NNRqCbPYKjqmUKCaF0ObmH8WUfd5
SHuFKRxBeAfu8picEBzgdRMUKgcgwjPiMN1BwONFTlkqgOj1sMvND/NW4peNTd0m
M45hZl3xbeUwLcTn/sI0Y74om0P78EGnc+5U1c5Cqq5HIxBNrg2V6cmj/IzkUws=
=J9qH
-----END PGP SIGNATURE-----

--vmttodhTwj0NAgWp--
