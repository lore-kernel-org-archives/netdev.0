From: Mikulas Patocka <mpatocka@redhat.com>
Subject: Re: crash with bridge and inconsistent handling of NETDEV_TX_OK
Date: Tue, 20 Apr 2010 20:23:57 -0400 (EDT)
Message-ID: <Pine.LNX.4.64.1004202018100.16302@hs20-bc2-1.build.redhat.com>
References: <Pine.LNX.4.64.1004201947470.29017@hs20-bc2-1.build.redhat.com>
 <20100420.170038.130590455.davem@davemloft.net>
 <Pine.LNX.4.64.1004202003010.13651@hs20-bc2-1.build.redhat.com>
 <20100420.171525.200010343.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: netdev@vger.kernel.org, kaber@trash.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35293 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752558Ab0DUA7z (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 20 Apr 2010 20:59:55 -0400
In-Reply-To: <20100420.171525.200010343.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Tue, 20 Apr 2010, David Miller wrote:

> From: Mikulas Patocka <mpatocka@redhat.com>
> Date: Tue, 20 Apr 2010 20:12:45 -0400 (EDT)
> 
> > Why is it using GSO on bridging?
> 
> Unlike LRO, GRO and GSO are completely valid in bridging and
> routing situations.
> 
> In fact, in virtualization environments it is essential for
> good performance.

I know it may be used for bridging. But it doesn't explain how it happened 
in my case.

I have two NICs, each with 1500 MTU. The stack trace indicates that a 
packet was received by one NIC and bridged to the other. The stack trace 
also indicates that it went through GSO code path. The question is why? 
How could a forwarded packet be so large to use GSO?

Mikulas
