From: etienne.champetier@free.fr
Subject: tun and routing
Date: Mon, 14 Apr 2014 13:47:13 +0200 (CEST)
Message-ID: <376498473.79151018.1397476033181.JavaMail.root@zimbra65-e11.priv.proxad.net>
References: <176092473.79093321.1397474889713.JavaMail.root@zimbra65-e11.priv.proxad.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp1-g21.free.fr ([212.27.42.1]:46507 "EHLO smtp1-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754930AbaDNLrP (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 14 Apr 2014 07:47:15 -0400
Received: from zimbra65-e11.priv.proxad.net (unknown [172.20.243.215])
	by smtp1-g21.free.fr (Postfix) with ESMTP id A93A2239BBFE
	for <netdev@vger.kernel.org>; Mon, 14 Apr 2014 13:47:11 +0200 (CEST)
In-Reply-To: <176092473.79093321.1397474889713.JavaMail.root@zimbra65-e11.priv.proxad.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

When the kernel gives a packet to a tun interface, you loose the "next-hop" information, because you only have L3+ infos.
So you have destination ip, but if it's out of the tun subnet, you have to do routing in your application. (with a tap interface the next-hop is the dest mac)

Is there a way to have this next-hop info, and remove "internal" (in the application) routing table?

If not what would be the cleanest way to sync the "internal" routing table with the kernel routing table?

Thanks in advance
Etienne
