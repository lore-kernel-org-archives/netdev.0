From: David Miller <davem@davemloft.net>
Subject: Re: [bug] sunhme unable to receive IPv4 unicasts
Date: Mon, 27 Oct 2014 19:03:46 -0400 (EDT)
Message-ID: <20141027.190346.920863541819947249.davem@davemloft.net>
References: <op.xn7d94v644i3fq@lx3.fl.yeti.dk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: WIMPy@yeti.dk
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:51693 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751949AbaJ0XDr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Oct 2014 19:03:47 -0400
In-Reply-To: <op.xn7d94v644i3fq@lx3.fl.yeti.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Birger Harzenetter" <WIMPy@yeti.dk>
Date: Fri, 24 Oct 2014 00:04:42 +0200

>  from https://bugzilla.kernel.org/show_bug.cgi?id=86731
> 
> Any kind of transmission is fine.
> Reception of IPv4 broadcast works
> Reception of non-IP works (pppoe tested)
> But IPv4 unicasts don't show up at all.
> IPv6 not tested
> 
> Additional tests:
> I tried to set promiscous mode, but still no trace of unicasts seen with  
> tcpdump.
> 
> Last known working version: 3.15.10

Unfortunately there have been zero functional changes to this driver
since v3.15 :-/
