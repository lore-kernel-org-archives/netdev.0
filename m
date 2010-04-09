From: Valdis.Kletnieks@vt.edu
Subject: Re: mmotm 2010-04-05-16-09 uploaded
Date: Thu, 08 Apr 2010 20:50:06 -0400
Message-ID: <8356.1270774206@localhost>
References: <201004052336.o35NaeSE015814@imap1.linux-foundation.org> <13074.1270663309@localhost> <4BBDC0CC.7080305@trash.net> <6795.1270740197@localhost>
            <4BBDF7E7.708@trash.net>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1270774206_4354P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	Peter Zijlstra <peterz@infradead.org>,
	Ingo Molnar <mingo@redhat.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netfilter-devel@vger.kernel.org,
	netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: Your message of "Thu, 08 Apr 2010 17:36:07 +0200."
             <4BBDF7E7.708@trash.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--==_Exmh_1270774206_4354P
Content-Type: text/plain; charset=us-ascii

On Thu, 08 Apr 2010 17:36:07 +0200, Patrick McHardy said:

> Valdis.Kletnieks@vt.edu wrote:

> > Well, it *changed* it.  Does the rcu_defererence_check() only fire on the
> > first time it hits something, so we've fixed the first one and now we get to
> > see the second one?
> 
> It appears that way, otherwise you should have seen a second warning in
> nf_conntrack_ecache the last time.
> 
> > (For what it's worth, if this is going to be one-at-a-time whack-a-mole, I'm
> > OK on that, just want to know up front.)
> 
> I went through the other files and I believe this should be it.
> We already removed most of these incorrect rcu_dereference()
> calls a while back.

Confirming - the second version of the patch fixes all the network-related
RCU complaints I've been able to trigger...

--==_Exmh_1270774206_4354P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Exmh version 2.5 07/13/2001

iD8DBQFLvnm+cC3lWbTT17ARAlV4AJ9LeqKJxNKJHopdR6TZztZiQKqb6wCfXlAs
6+jWKabDR4mVLHFUHMYljSA=
=guT+
-----END PGP SIGNATURE-----

--==_Exmh_1270774206_4354P--
