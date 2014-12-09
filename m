From: Valdis.Kletnieks@vt.edu
Subject: Re: linux-next 20141208 - net/sched/sch_fq_codel.c:97 suspicious RCU
Date: Tue, 09 Dec 2014 13:54:48 -0500
Message-ID: <9914.1418151288@turing-police.cc.vt.edu>
References: <6468.1418147500@turing-police.cc.vt.edu>
            <CANn89iJAN815z3TefSjj0uZyQQyH-wTiAckt3WeMc-F7DRgpKA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: multipart/signed; boundary="==_Exmh_1418151288_3854P";
	 micalg=pgp-sha1; protocol="application/pgp-signature"
Content-Transfer-Encoding: 7bit
Cc: John Fastabend <john.r.fastabend@intel.com>,
	"David S. Miller" <davem@davemloft.net>,
	linux-kernel@vger.kernel.org, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <edumazet@google.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: Your message of "Tue, 09 Dec 2014 10:07:31 -0800."
             <CANn89iJAN815z3TefSjj0uZyQQyH-wTiAckt3WeMc-F7DRgpKA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--==_Exmh_1418151288_3854P
Content-Type: text/plain; charset=us-ascii

On Tue, 09 Dec 2014 10:07:31 -0800, Eric Dumazet said:
> On Tue, Dec 9, 2014 at 9:51 AM, Valdis Kletnieks

> > commit 46e5da40aec256155cfedee96dd21a75da941f2c
> > Author: John Fastabend <john.fastabend@gmail.com>
> > Date:   Fri Sep 12 20:04:52 2014 -0700
>
> Well, its a (harmless) typo : this should really be an
> rcu_dereference_bh() instead of rcu_dereference()

You want a patch, or you got it already?


--==_Exmh_1418151288_3854P
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1
Comment: Exmh version 2.5 07/13/2001

iQIVAwUBVIdFeAdmEQWDXROgAQI76g//eRKu5vEoYsqvWueWLLtx8QNwAPBDSKoG
hXvkwd7ud3me1wCibHmcsyzI8YkA+8ZD1QkrSSbPWdWWAngOFM9ZLwmYRzzEeZ90
qMyprtml8HYNoL5ij1W0Su2Z1KhwIbXrrAWe+NL/HNZymVjR0aV+g4T/eHJ0APOC
99I6yJm9yCU1mpnoidDhHuUC0oPSJX5PQK5Kq71jfan/dAQ7XLaHZrqapJw0v9aV
z7+FV0NjzcCAQPYKumgDnEmzpYnDYdQlMGqm/yHM3yQ2bNnn3eVf6/3WHRm/P+Zy
tLSw+oJ73yWWLrl5WBylLANe7K8B2c7aH3pT5NMai12JsZ9psr2pDA+7M/vZvIye
cvb0Y3vWXip9Jhc+rKQLdJjttSpaYOceZtZ6+n0uuwWvNbiKGkoDBNDHx09RrvTb
e39vtvToABvNjVPIANVtzALvWl18TvPJTniZwKVpXrspwxoS4kLx2/mYgFLosznn
48Q/Kgw7yoqfIvFrixOaE/p9gw4UDn8C79VWdy5wXzBibK3HoHQlDuDWX3vKacv7
HagOYvKTR1JodDXrlxkVdleNcuvZYj9R940DVFh/HUyZuhucByGYroTk5UeXNKun
ChS7dMYSaSZxkmeikMrrVMJSIk9i9AOwyWTV4CvIv+QU9zBhhaG5PbQaLMVhfStT
TeJTVpdo81o=
=r3YD
-----END PGP SIGNATURE-----

--==_Exmh_1418151288_3854P--
