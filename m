From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] ipv6: dst_allfrag() not taken into account by TCP
Date: Tue, 17 Jan 2012 13:25:17 -0500 (EST)
Message-ID: <20120117.132517.1344543741371484900.davem@davemloft.net>
References: <1326817699.2259.32.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
	<20120117.123405.2126678655326303069.davem@davemloft.net>
	<1326824111.2259.54.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, tore@fud.no
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([198.137.202.13]:56454 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751128Ab2AQS0Z (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Jan 2012 13:26:25 -0500
In-Reply-To: <1326824111.2259.54.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Tue, 17 Jan 2012 19:15:11 +0100

> We could change net_header_len to be a method, and for ipv6 do :

Or add a icsk_frag_hdr_len (or something in proto ops) and do the
dst_allfrag() test inline.
