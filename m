From: David Miller <davem@davemloft.net>
Subject: Re: [Bug 106241] New: shutdown(3)/close(3) behaviour is incorrect
 for sockets in accept(3)
Date: Wed, 21 Oct 2015 18:29:55 -0700 (PDT)
Message-ID: <20151021.182955.1434243485706993231.davem@davemloft.net>
References: <20151021034950.GL22011@ZenIV.linux.org.uk>
	<5627A37B.4090208@oracle.com>
	<20151021185104.GM22011@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Alan.Burlison@oracle.com, eric.dumazet@gmail.com,
	stephen@networkplumber.org, netdev@vger.kernel.org,
	dholland-tech@netbsd.org, casper.dik@oracle.com
To: viro@ZenIV.linux.org.uk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:49571 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751023AbbJVBNh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Oct 2015 21:13:37 -0400
In-Reply-To: <20151021185104.GM22011@ZenIV.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Al Viro <viro@ZenIV.linux.org.uk>
Date: Wed, 21 Oct 2015 19:51:04 +0100

> Sure, but the upkeep of data structures it would need is there
> whether you actually end up triggering it or not.  Both in
> memory footprint and in cacheline pingpong...

+1
