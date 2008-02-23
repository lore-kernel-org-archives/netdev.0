From: Sebastian Siewior <bigeasy@breakpoint.cc>
Subject: Re: [PATCH] [PS3] gelic wireless driver needs MAC80211 support
Date: Sat, 23 Feb 2008 21:06:37 +0100
Message-ID: <20080223200637.GA7135@Chamillionaire.breakpoint.cc>
References: <20080223193517.GA6704@Chamillionaire.breakpoint.cc> <200802232044.59887.IvDoorn@gmail.com> <200802232050.35157.IvDoorn@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-15
Cc: Sebastian Siewior <netdev@ml.breakpoint.cc>,
	Masakazu Mokuno <mokuno@sm.sony.co.jp>, jgarzik@pobox.com,
	netdev@vger.kernel.org
To: Ivo van Doorn <ivdoorn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([85.10.199.196]:52605 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1764017AbYBWUHC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 23 Feb 2008 15:07:02 -0500
Content-Disposition: inline
In-Reply-To: <200802232050.35157.IvDoorn@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

* Ivo van Doorn | 2008-02-23 20:50:34 [+0100]:

>Additionally, what part of the driver actually uses mac80211?
>I just browsed to the code, and it seems to work completely without
>using mac80211. Instead it seems to work directly by registering a
>net_device structure...
  CC      drivers/net/ps3_gelic_wireless.o
/home/bigeasy/git/linux-2.6/drivers/net/ps3_gelic_wireless.c: In function 'gelic_wl_setup_netdev_ops':
/home/bigeasy/git/linux-2.6/drivers/net/ps3_gelic_wireless.c:2660: error: 'struct net_device' has no member named 'wireless_data'
/home/bigeasy/git/linux-2.6/drivers/net/ps3_gelic_wireless.c:2661: error: 'struct net_device' has no member named 'wireless_handlers'
make[3]: *** [drivers/net/ps3_gelic_wireless.o] Error 1
make[2]: *** [drivers/net] Error 2
make[1]: *** [drivers] Error 2
make[1]: *** Waiting for unfinished jobs....
make: *** [sub-make] Error 2


I add this to the patch desctiption and post a depends on patach

>Ivo

Sebastian
