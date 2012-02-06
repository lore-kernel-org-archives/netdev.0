From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: BUG: unable to handle kernel NULL pointer dereference at
 000000000000002c
Date: Mon, 06 Feb 2012 10:16:58 +0100
Message-ID: <1328519818.2220.1.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <20120201.162157.880976652659067010.davem@davemloft.net>
			 <4F2A87B0.6070900@profihost.ag>
			 <1328195055.2279.61.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
			 <20120202.143957.2251106530056768980.davem@davemloft.net>
			 <20120203004228.GA23429@kroah.com> <4F2B8348.3090305@profihost.ag>
		 <1328253972.2480.42.camel@edumazet-laptop> <4F2B963F.4020504@profihost.ag>
	 <1328267097.2157.17.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	 <4F2F971B.9090503@profihost.ag>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Greg KH <gregkh@linuxfoundation.org>,
	David Miller <davem@davemloft.net>, jwboyer@gmail.com,
	hch@infradead.org, netdev@vger.kernel.org, david@fromorbit.com,
	stable@vger.kernel.org, gregkh@suse.de
To: Stefan Priebe - Profihost AG <s.priebe@profihost.ag>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:58434 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752719Ab2BFJRB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Feb 2012 04:17:01 -0500
In-Reply-To: <4F2F971B.9090503@profihost.ag>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 06 f=C3=A9vrier 2012 =C3=A0 10:02 +0100, Stefan Priebe - Profi=
host AG a
=C3=A9crit :

> how to get an allyesconfig? Or just doing something like:
> rm -f .config; /usr/bin/yes | make oldconfig

Save your .config, since next step will destroy it :

make allyesconfig

Then build :

make   $your_favorite_build_options
