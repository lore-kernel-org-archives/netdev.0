From: David Miller <davem@davemloft.net>
Subject: Re: [Bug 106241] New: shutdown(3)/close(3) behaviour is incorrect
 for sockets in accept(3)
Date: Thu, 29 Oct 2015 18:54:49 -0700 (PDT)
Message-ID: <20151029.185449.456371093991888866.davem@davemloft.net>
References: <56324625.9000803@oracle.com>
	<20151029170748.GG22011@ZenIV.linux.org.uk>
	<5632538C.7070401@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: viro@ZenIV.linux.org.uk, eric.dumazet@gmail.com,
	stephen@networkplumber.org, netdev@vger.kernel.org
To: Alan.Burlison@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:59386 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752268AbbJ3BiD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Oct 2015 21:38:03 -0400
In-Reply-To: <5632538C.7070401@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alan Burlison <Alan.Burlison@oracle.com>
Date: Thu, 29 Oct 2015 17:12:44 +0000

> On 29/10/2015 17:07, Al Viro wrote:
> 
>> Could the esteemed sir possibly be ars^H^H^Hprevailed upon to quote
>> the exact
>> place in POSIX that requires such behaviour?
> 
> If that's the way the conversation is going to go, sorry, no.

I find Al's request to be frankly quite reasonable, as is his
frustration expressed in his tone as well.

Furthermore, NetBSD's intention to try and get rid of the
close() on accept() behavior shows that the Linux developers
are not in the minority of being against requiring this
behavior or even finding it desirable in any way.
