From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: Re: [PATCH 1/2] [IPV4] UDP: Always checksum even if without socket filter
Date: Thu, 29 Nov 2007 10:56:48 +0000
Message-ID: <20071129105648.GB17629@gerrit.erg.abdn.ac.uk>
References: <20071119.142313.63549156.davem@davemloft.net> <20071120002945.91fafb2b.billfink@mindspring.com> <20071120140518.GA1502@one.firstfloor.org> <20071120.173928.53148729.davem@davemloft.net> <474E707A.3080106@cn.fujitsu.com> <20071129092136.GB30066@gondor.apana.org.au> <474E8F9E.7040309@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>, andi@firstfloor.org,
	netdev@vger.kernel.org, bfields@fieldses.org, neilb@suse.de
To: Wang Chen <wangchen@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:45273 "EHLO erg.abdn.ac.uk"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750987AbXK2K6s (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Nov 2007 05:58:48 -0500
Content-Disposition: inline
In-Reply-To: <474E8F9E.7040309@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Thank you for doing this work, there is a small comment below.

| --- linux-2.6.24.rc3.org/Documentation/networking/udplite.txt	2007-11-19 12:37:40.000000000 +0800
| +++ linux-2.6.24.rc3/Documentation/networking/udplite.txt	2007-11-28 18:35:29.000000000 +0800
| @@ -236,7 +236,7 @@
|  
|    This displays UDP-Lite statistics variables, whose meaning is as follows.
|  
| -   InDatagrams:     Total number of received datagrams.
| +   InDatagrams:     The total number of UDP datagrams delivered to UDP users.
You are in the UDP-Lite documentation -- it should read "UDP-Lite", not UDP.
