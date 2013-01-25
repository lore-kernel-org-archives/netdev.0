From: Valdis.Kletnieks@vt.edu
Subject: Re: [Web10g-user] Web10g TCP statistics patch - mainlining into kernel?
Date: Fri, 25 Jan 2013 13:57:57 -0500
Message-ID: <20357.1359140277@turing-police.cc.vt.edu>
References: <18855.1359138716@turing-police.cc.vt.edu>
            <CAO1dsSdQJDKZ+zzCaLgge9wqiNaJFzPWWBLjRkMEswLVOOd0qA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1359140277_1992P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	web10g-user@web10g.org
To: Dominic Hamon <dominic@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: Your message of "Fri, 25 Jan 2013 10:38:59 -0800."
             <CAO1dsSdQJDKZ+zzCaLgge9wqiNaJFzPWWBLjRkMEswLVOOd0qA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--==_Exmh_1359140277_1992P
Content-Type: text/plain; charset=us-ascii

On Fri, 25 Jan 2013 10:38:59 -0800, Dominic Hamon said:
> Hello Valdis
>
> I actually just finished patching a fork from the kernel github repo here:
> https://github.com/dominic-mlab/linux with a view to pushing it up. I
> haven't pushed a patch upstream before, so any guidance is welcome.

A quick browse over that git repo looks like it's unfortunately a tad
busticated - you've apparently got development on the 'master' branch, instead
of starting a separate branch.  This effectively means that it can't be easily
pulled upstream.  Fortunately, you only have one commit against it so
far, so you can probably recover by rejecting that commit so you're back
to a Linus tree, and then create a branch and do subsequent development there.

Question for the netdev people - you prefer pull requests based off
a Linus tree, or linux-next, davem/(net,net-next), or some other tree?


--==_Exmh_1359140277_1992P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.13 (GNU/Linux)
Comment: Exmh version 2.5 07/13/2001

iQIVAwUBUQLVtAdmEQWDXROgAQLKeBAAjqyb56sG//vtJCN2U7Zyw0IFyrlS28zY
gjAEwkPKWKWEf/Y2Iy6/E0Z1QPTvVDRGsI8/r3lmgMmGFcsiOCo5ZNEyu8vJNkD/
c37lrE1rJF1vNLbWiz+/lPRY3VZnvszqokwNW/YFvipb5VorHvY+69vDn2pmR5z8
zxeALrIc2GIWfB0H+K8WP3OXTWw6Z37P1dQp/oWYEMVODMGf4dYfdQGIvpoPc/w6
6zXkMx2FRX35aF2xdbRfSj7pfwM297wlsLwBuitqlukBthsWab9zxLCNNU4AmdWw
MVk/OeW/jl0aUS409CvNHoa/aePAbTpuAKIAq5jnzR7ybwDEGraCyxm52jKLgZTO
tiHwngIfUvSaVpEsrihYRZmRk4Eln993LXGM9dGoZPk091ronbSJ6SMhxxN1T0qg
luZMDXp+cFRGetkBIatz9OGS1gpcYPbG+yZDuGOL2b/tIC2Xqy0zASBpIWurB43F
AAJM9HwdEi3dmCizJDlHrnoUIbNMtMRJ4Fcg4gRaES7fZn1QvMrNvIlJvfO60wH/
gJOKmhJam2avijEkaJH0EAwXZt54hu0vZ0WQg3bxwKc6JIltHUSToQZjZOVmN3Nc
ogZjcZe6uUA951S1y8zSoGFi0fqppG+35xsLwC9x8Tk+fT9yiOpTIzs8j1rMmutV
flKfgXIGc4M=
=kz1o
-----END PGP SIGNATURE-----

--==_Exmh_1359140277_1992P--
