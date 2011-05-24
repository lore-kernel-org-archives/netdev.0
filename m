From: Rolf Eike Beer <eike-kernel@sf-tec.de>
Subject: Re: PA-RISC: compile error in include/net/dst.h
Date: Tue, 24 May 2011 20:37:49 +0200
Message-ID: <2522442.xP32cQyJEX@donald.sf-tec.de>
References: <2612811.b2htuyZy9x@donald.sf-tec.de>
	<20110522143222.GB14556@kroah.com>
	<2254093.9oQvKLogfV@donald.sf-tec.de>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="===============4071562325381053106=="
Cc: netdev@vger.kernel.org, linux-kernel <linux-kernel@vger.kernel.org>,
        Parisc List <linux-parisc@vger.kernel.org>, stable@kernel.org
To: Greg KH <greg@kroah.com>
Return-path: <stable-bounces@linux.kernel.org>
In-Reply-To: <2254093.9oQvKLogfV@donald.sf-tec.de>
List-Unsubscribe: <http://linux.kernel.org/mailman/options/stable>,
	<mailto:stable-request@linux.kernel.org?subject=unsubscribe>
List-Archive: <http://linux.kernel.org/mailman/private/stable/>
List-Post: <mailto:stable@linux.kernel.org>
List-Help: <mailto:stable-request@linux.kernel.org?subject=help>
List-Subscribe: <http://linux.kernel.org/mailman/listinfo/stable>,
	<mailto:stable-request@linux.kernel.org?subject=subscribe>
Sender: stable-bounces@linux.kernel.org
Errors-To: stable-bounces@linux.kernel.org
List-Id: netdev.vger.kernel.org


--===============4071562325381053106==
Content-Type: multipart/signed; boundary="nextPart3541033.Jq7cWPDluZ"; micalg="pgp-sha1"; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7Bit


--nextPart3541033.Jq7cWPDluZ
Content-Transfer-Encoding: 7Bit
Content-Type: text/plain; charset="ISO-8859-1"

I wrote:
> Am Sonntag, 22. Mai 2011, 07:32:22 schrieb Greg KH:
> > On Sun, May 22, 2011 at 10:15:19AM +0200, Rolf Eike Beer wrote:
> > >                  from include/net/ipv6.h:16,
> > >                  from
> > >                  include/linux/sunrpc/clnt.h:25,
> > >                  from include/linux/nfs_fs.h:50,
> > > 
> > >                  from init/do_mounts.c:20:
> > > include/net/dst.h: In function 'dst_hold':
> > > include/net/dst.h:238:2: error: size of unnamed array is negative
> > > In file included from include/linux/nfs_fs.h:59:0,
> > > 
> > >                  from init/do_mounts.c:20:
> > > include/linux/mempool.h: In function 'mempool_create_kmalloc_pool':
> > > include/linux/mempool.h:58:10: warning: cast to pointer from integer
> > > of
> > > different size
> > > 
> > > This is both in 2.6.38.6 and 2.6.39, but is not in 2.6.38.4 when
> > > compiling for my C8000.
> > 
> > Could you bisect it down to the patch that causes the problem in
> > 2.6.38.6?
> 
> I will try if I find time in the next days. Until now I can only confirm
> that 2.6.38.5 builds fine.

As 2.6.38.6 does if I use the correct .config. So it is an older issue which is 
not related to recent changes but likely some general HPPA breakage. We'll 
discuss the rest on linux-parisc.

Eike
--nextPart3541033.Jq7cWPDluZ
Content-Type: application/pgp-signature; name="signature.asc"
Content-Description: This is a digitally signed message part.

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.15 (GNU/Linux)

iEYEABECAAYFAk3b+v0ACgkQXKSJPmm5/E5JtwCfXbn0WubfIblCw+/NIb7z23oB
OpUAniuTRy4AShlOK718waVyBsje/CYi
=vhmF
-----END PGP SIGNATURE-----

--nextPart3541033.Jq7cWPDluZ--


--===============4071562325381053106==
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
stable mailing list
stable@linux.kernel.org
http://linux.kernel.org/mailman/listinfo/stable

--===============4071562325381053106==--
