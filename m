From: =?iso-8859-1?Q?L=2E_Alberto_Gim=E9nez?= <agimenez@sysvalve.es>
Subject: Re: [patch] ipheth: potential null dereferences on error path
Date: Tue, 27 Apr 2010 23:00:03 +0200
Message-ID: <20100427210003.GA13873@bart.evergreen.loc>
References: <20100427092012.GA29093@bicker>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Diego Giagio <diego@giagio.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org
To: Dan Carpenter <error27@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 152.Red-88-2-254.staticIP.rima-tde.net ([88.2.254.152]:47974
	"HELO sysvalve.homelinux.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1755950Ab0D0VAG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Apr 2010 17:00:06 -0400
Content-Disposition: inline
In-Reply-To: <20100427092012.GA29093@bicker>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 27, 2010 at 11:20:12AM +0200, Dan Carpenter wrote:
> The calls to usb_free_buffer() dereference rx_urb and tx_urb in the
> parameter list but those could be NULL.
>=20
> Signed-off-by: Dan Carpenter <error27@gmail.com>

Seems good to me (should I ack it or any other kind of singoff?).

--=20
L. Alberto Gim=E9nez
JabberID agimenez@jabber.sysvalve.es
GnuPG key ID 0x3BAABDE1
