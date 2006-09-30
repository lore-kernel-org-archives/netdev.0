From: Valdis.Kletnieks@vt.edu
Subject: Re: 2.6.18-mm2 - oops in cache_alloc_refill()
Date: Fri, 29 Sep 2006 23:31:07 -0400
Message-ID: <200609300331.k8U3V71c008874@turing-police.cc.vt.edu>
References: <20060928014623.ccc9b885.akpm@osdl.org> <200609290319.k8T3JOwS005455@turing-police.cc.vt.edu> <20060928202931.dc324339.akpm@osdl.org> <200609291519.k8TFJfvw004256@turing-police.cc.vt.edu> <20060929124558.33ef6c75.akpm@osdl.org> <200609300001.k8U01sPI004389@turing-police.cc.vt.edu> <20060929182008.fee2a229.akpm@osdl.org>
            <20060930013348.GA10905@bougret.hpl.hp.com>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1159587067_2769P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@osdl.org>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from pool-72-66-199-147.ronkva.east.verizon.net ([72.66.199.147]:9159
	"EHLO turing-police.cc.vt.edu") by vger.kernel.org with ESMTP
	id S1750736AbWI3Dhb (ORCPT <RFC822;netdev@vger.kernel.org>);
	Fri, 29 Sep 2006 23:37:31 -0400
To: jt@hpl.hp.com
In-Reply-To: Your message of "Fri, 29 Sep 2006 18:33:48 PDT."
             <20060930013348.GA10905@bougret.hpl.hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--==_Exmh_1159587067_2769P
Content-Type: text/plain; charset=us-ascii

On Fri, 29 Sep 2006 18:33:48 PDT, Jean Tourrilhes said:
> On Fri, Sep 29, 2006 at 06:20:08PM -0700, Andrew Morton wrote:
> > On Fri, 29 Sep 2006 20:01:54 -0400
> > > 
> > > Here's the traceback I got:
> > > 
> > > slab error in verify_redzone_free(): cache `size-32': memory outside object was overwritten

> 	Hum... Not clear what's happening. I'll look more into it on
> monday.

Fair enough,  I'm going to try reverting the 2 commits and see if things
behave better.

> 	I'm using Orinoco, I've not seen that with iwconfig.
> 	I'll look into that...

I'll bet it's the difference between a modern iwconfig and a 3-year-old
stone-age gkrellm plugin :)

--==_Exmh_1159587067_2769P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.5 (GNU/Linux)
Comment: Exmh version 2.5 07/13/2001

iD8DBQFFHeT7cC3lWbTT17ARAmL1AKCDMhRrjdE3MwpAV3XkB9WZ+ISkDgCg0jZa
bpgm37/RX4gHpAjVM7No7u8=
=tBw2
-----END PGP SIGNATURE-----

--==_Exmh_1159587067_2769P--
