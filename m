From: Cyrill Gorcunov <gorcunov@gmail.com>
Subject: Re: [PATCH 08/43] drivers/net/ppp*.c: fix sparse warnings: fix
	signedness
Date: Sun, 15 Feb 2009 00:38:48 +0300
Message-ID: <20090214213848.GF7648@localhost>
References: <20090214210940.23489.95001.stgit@vmbox.hanneseder.net> <20090214211346.23489.96321.stgit@vmbox.hanneseder.net> <20090214212948.GE7648@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: Hannes Eder <hannes@hanneseder.net>, netdev@vger.kernel.org,
	kernel-janitors@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f21.google.com ([209.85.219.21]:49450 "EHLO
	mail-ew0-f21.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754081AbZBNVit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 14 Feb 2009 16:38:49 -0500
Content-Disposition: inline
In-Reply-To: <20090214212948.GE7648@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[Cyrill Gorcunov - Sun, Feb 15, 2009 at 12:29:48AM +0300]
| [Hannes Eder - Sat, Feb 14, 2009 at 10:13:52PM +0100]
| | Fix this sparse warnings:
| |   drivers/net/ppp_generic.c:919:43: warning: incorrect type in argument 1 (different signedness)
| |   drivers/net/pppoe.c:1195:43: warning: incorrect type in argument 1 (different signedness)
| |   drivers/net/pppol2tp.c:2666:43: warning: incorrect type in argument 1 (different signedness)
| | 
| | Signed-off-by: Hannes Eder <hannes@hanneseder.net>
| ...
| 
| Thanks Hannes,
| 
| Acked-by: Cyrill Gorcunov <gorcunov@openvz.org>
| 
| 	- Cyrill -

Btw I think the same fix could be applied on
drivers/net/tun.c (if you have time for :)

	- Cyrill -
