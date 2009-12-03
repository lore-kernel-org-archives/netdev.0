From: Greg KH <gregkh@suse.de>
Subject: Re: scp stalls mysteriously
Date: Thu, 3 Dec 2009 10:32:07 -0800
Message-ID: <20091203183207.GA13626@suse.de>
References: <20091201211945.505d3c98@houba>
 <alpine.DEB.2.00.0912012220570.1904@melkinpaasi.cs.helsinki.fi>
 <20091202085925.472136e2@houba>
 <alpine.DEB.2.00.0912021438030.20416@melkinpaasi.cs.helsinki.fi>
 <20091202154403.GB30730@sd-11162.dedibox.fr>
 <alpine.DEB.2.00.0912021745200.7024@wel-95.cs.helsinki.fi>
 <20091202183451.173db5f2@houba>
 <4B16BD58.3040802@tvk.rwth-aachen.de>
 <20091203085933.GD30730@sd-11162.dedibox.fr>
 <alpine.DEB.2.00.0912031121190.7024@wel-95.cs.helsinki.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Frederic Leroy <fredo@starox.org>,
	Damian Lukowski <damian@tvk.rwth-aachen.de>,
	Netdev <netdev@vger.kernel.org>, Asdo <asdo@shiftmail.org>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: Ilpo =?iso-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cantor.suse.de ([195.135.220.2]:37213 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756133AbZLCScM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Dec 2009 13:32:12 -0500
Content-Disposition: inline
In-Reply-To: <alpine.DEB.2.00.0912031121190.7024@wel-95.cs.helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 03, 2009 at 12:29:39PM +0200, Ilpo J=E4rvinen wrote:
> I've added Greg as CC to make him aware of this issue in early as it =
now=20
> affects 2.6.32 too (rather important to get dealt quickly in stable o=
nce=20
> we have a tested solution since TCP is pretty broken with the silent=20
> deaths this problem seems to cause). ...One possibility would be to j=
ust=20
> queue the tested revert to stable and sort this thing out for 2.6.33 =
in=20
> net-2.6.
>=20
> Opinions, Dave?, Greg?

As always, if you have a patch that you want in the -stable tree, send
it, with the git commit id of the patch that is in Linus's tree, to the
stable@kernel.org email address so I don't loose it.

thanks,

greg k-h
