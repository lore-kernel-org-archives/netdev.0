From: David Miller <davem@davemloft.net>
Subject: Re: 2.6.32-rc5-mmotm1101 - kernel BUG at net/ipv4/tcp_input.c:3707!
Date: Tue, 03 Nov 2009 18:34:35 -0800 (PST)
Message-ID: <20091103.183435.209882374.davem@davemloft.net>
References: <4AF08292.7090102@codefidence.com>
	<Pine.LNX.4.64.0911032330090.3488@melkinkari.cs.Helsinki.FI>
	<7916.1257300093@turing-police.cc.vt.edu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: ilpo.jarvinen@helsinki.fi, gilad@codefidence.com,
	eric.dumazet@gmail.com, akpm@linux-foundation.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	ori@comsleep.com
To: Valdis.Kletnieks@vt.edu
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:49523
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750751AbZKDCeK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Nov 2009 21:34:10 -0500
In-Reply-To: <7916.1257300093@turing-police.cc.vt.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Valdis.Kletnieks@vt.edu
Date: Tue, 03 Nov 2009 21:01:33 -0500

> Why was this blowing chunks in the IPv6 when I was making an IPv4 connection
> then? I just noticed that. My fetchmail can't make an IPv6 TCP connection to
> our IMAP server because the server isn't v6-enabled yet.  And although I
> contact our DNS over IPv6, but that's UDP not TCP.

Many things IPV6 capable will go through the IPV4 compat
path of the IPV6 stack, depending upon how listening sockets
configure themselves etc.
