From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] r8169 : why SG / TX checksum are default disabled
Date: Fri, 20 Jul 2012 09:28:15 -0700 (PDT)
Message-ID: <20120720.092815.1277013689568598933.davem@davemloft.net>
References: <EF06A7B3C1E6432BB660CDEF8E1D2A1B@realtek.com.tw>
	<20120720100846.GA17398@electric-eye.fr.zoreil.com>
	<A4FD513AF09D40849B8A75C371F1D431@realtek.com.tw>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: romieu@fr.zoreil.com, eric.dumazet@gmail.com,
	netdev@vger.kernel.org
To: hayeswang@realtek.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53427 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750925Ab2GTQ2Q (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jul 2012 12:28:16 -0400
In-Reply-To: <A4FD513AF09D40849B8A75C371F1D431@realtek.com.tw>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: hayeswang <hayeswang@realtek.com>
Date: Sat, 21 Jul 2012 00:01:38 +0800

> However, the hw would also fill in the total length field of IP
> header, so it causes problems.

Why does the HW modify fields we did not ask it to?
