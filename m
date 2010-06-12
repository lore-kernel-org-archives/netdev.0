From: Markus Trippelsdorf <markus@trippelsdorf.de>
Subject: mpd client timeouts (bisected) 2.6.35-rc3
Date: Sat, 12 Jun 2010 12:28:02 +0200
Message-ID: <20100612102802.GA1782@arch.tripp.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	davem@davemloft.net
To: john.r.fastabend@intel.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Commit 597a264b1a9c7e36d1728f677c66c5c1f7e3b837:
=BBnet: deliver skbs on inactive slaves to exact matches=AB

causes large timeouts when mpd clients try to connect to a locally
running mpd (music player demon) on my machine. This makes it=20
impossible to control mpd.

I bisected this down to the commit mentioned above.
Reverting the commit from 2.6.35-rc3 also solves the problem.

--=20
Markus
