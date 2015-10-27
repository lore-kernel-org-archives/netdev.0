From: David Miller <davem@davemloft.net>
Subject: Re: [Bug 106241] New: shutdown(3)/close(3) behaviour is incorrect
 for sockets in accept(3)
Date: Tue, 27 Oct 2015 08:04:34 -0700 (PDT)
Message-ID: <20151027.080434.2260743137698389975.davem@davemloft.net>
References: <562F868B.4040001@oracle.com>
	<20151027.073914.310976982324296607.davem@davemloft.net>
	<562F8CBC.7080800@oracle.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Casper.Dik@oracle.com, viro@ZenIV.linux.org.uk,
	eric.dumazet@gmail.com, stephen@networkplumber.org,
	netdev@vger.kernel.org, dholland-tech@netbsd.org
To: Alan.Burlison@oracle.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:38919 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932345AbbJ0Or5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Oct 2015 10:47:57 -0400
In-Reply-To: <562F8CBC.7080800@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alan Burlison <Alan.Burlison@oracle.com>
Date: Tue, 27 Oct 2015 14:39:56 +0000

> On 27/10/2015 14:39, David Miller wrote:
> 
>> Making this worse is that there isn't going to be a straightforward
>> nor reliable way to test for the presence of this at run time.
> 
> I attached a test case to the original bug that demonstrates the
> platform-specific behaviours, it would be easy enough to modify that
> to use as a configure-time feature probe.

I said "run time".  Like when your final code runs on a target system.

Not at build tree configure time.
