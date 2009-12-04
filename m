From: Frederic Leroy <fredo@starox.org>
Subject: Re: scp stalls mysteriously
Date: Fri, 4 Dec 2009 10:36:29 +0100
Message-ID: <20091204093629.GA17976@sd-11162.dedibox.fr>
References: <alpine.DEB.2.00.0912021745200.7024@wel-95.cs.helsinki.fi> <20091202183451.173db5f2@houba> <4B16BD58.3040802@tvk.rwth-aachen.de> <20091203085933.GD30730@sd-11162.dedibox.fr> <alpine.DEB.2.00.0912031121190.7024@wel-95.cs.helsinki.fi> <4B17A791.80808@tvk.rwth-aachen.de> <alpine.DEB.2.00.0912031444150.7024@wel-95.cs.helsinki.fi> <4B17C6C3.1060000@tvk.rwth-aachen.de> <20091203202328.62d7551a@houba> <4B1820B8.7050500@tvk.rwth-aachen.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ilpo =?iso-8859-1?Q?J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	Netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Greg KH <gregkh@suse.de>
To: Damian Lukowski <damian@tvk.rwth-aachen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sd-11162.dedibox.fr ([88.191.70.230]:59645 "EHLO
	sd-11162.dedibox.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751592AbZLDJgX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Dec 2009 04:36:23 -0500
Content-Disposition: inline
In-Reply-To: <4B1820B8.7050500@tvk.rwth-aachen.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 03, 2009 at 09:34:00PM +0100, Damian Lukowski wrote:
> Frederic Leroy schrieb:
>
> Ok, at least this "fix" seems to work at first glance, but the printk
> is quite useless now. Could you run another test with the printk's but
> without the retrans_stamp == 0 check, please?

I just made 3 more test (.14 .15 .16), all streams has failed.
