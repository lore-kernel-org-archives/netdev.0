From: Valdis.Kletnieks@vt.edu
Subject: Re: 2.6.34-rc5-mmotm0428 - 2 RCU whinges in mac80211
Date: Thu, 06 May 2010 14:29:44 -0400
Message-ID: <8269.1273170584@localhost>
References: <5820.1273167313@localhost>
            <1273168696.23199.0.camel@jlt3.sipsolutions.net>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1273170584_4094P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>,
	"John W. Linville" <linville@tuxdriver.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-wireless@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: Your message of "Thu, 06 May 2010 19:58:16 +0200."
             <1273168696.23199.0.camel@jlt3.sipsolutions.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--==_Exmh_1273170584_4094P
Content-Type: text/plain; charset=us-ascii

On Thu, 06 May 2010 19:58:16 +0200, Johannes Berg said:
> On Thu, 2010-05-06 at 13:35 -0400, Valdis.Kletnieks@vt.edu wrote:
> > Spotted these in my dmesg, hopefully somebody is interested...
> > 
> > [   54.076863] wlan0: deauthenticating from 00:11:20:a4:4c:11 by local choice (reason=3)
> > [   54.080580] 
> > [   54.080581] ===================================================
> > [   54.080584] [ INFO: suspicious rcu_dereference_check() usage. ]
> > [   54.080586] ---------------------------------------------------
> > [   54.080589] net/mac80211/sta_info.c:858 invoked rcu_dereference_check() without protection!
> 
> I'm pretty sure I fixed those so there should be a patch on its way to
> or in mainline somewhere.

Oh,  OK.  I didn't remember seeing them mentioned before, but I must have
missed somebody else's post about it due to the lkml firehose effect. I've
moved these to my "whinge if it isn't fixed in the next -mmotm" queue.


--==_Exmh_1273170584_4094P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.10 (GNU/Linux)
Comment: Exmh version 2.5 07/13/2001

iD8DBQFL4wqYcC3lWbTT17ARArwmAJ9LGHTpYagAUMm99LssnBt4wXq9TACffiKa
sLhU9+s1wcwIGoTU9C7LjK0=
=dTom
-----END PGP SIGNATURE-----

--==_Exmh_1273170584_4094P--
