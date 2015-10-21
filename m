From: David Miller <davem@davemloft.net>
Subject: Re: [Bug 106241] New: shutdown(3)/close(3) behaviour is incorrect
 for sockets in accept(3)
Date: Wed, 21 Oct 2015 08:30:08 -0700 (PDT)
Message-ID: <20151021.083008.1870598627666404990.davem@davemloft.net>
References: <1445305532.30896.40.camel@edumazet-glaptop2.roam.corp.google.com>
	<20151021034950.GL22011@ZenIV.linux.org.uk>
	<5627A37B.4090208@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: viro@ZenIV.linux.org.uk, eric.dumazet@gmail.com,
	stephen@networkplumber.org, netdev@vger.kernel.org,
	dholland-tech@netbsd.org, casper.dik@oracle.com
To: Alan.Burlison@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:44936 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753823AbbJUPNo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Oct 2015 11:13:44 -0400
In-Reply-To: <5627A37B.4090208@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alan Burlison <Alan.Burlison@oracle.com>
Date: Wed, 21 Oct 2015 15:38:51 +0100

> While this algorithm is pretty expensive, it is not often invoked.

I bet it can be easily intentionally invoked, by a malicious entity no
less.
