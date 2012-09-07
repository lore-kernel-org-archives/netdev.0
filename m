From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/2] dst: take into account policy update on check()
Date: Fri, 07 Sep 2012 17:08:29 +0200
Message-ID: <1347030509.2484.774.camel@edumazet-glaptop>
References: <5049FAE3.2050403@6wind.com>
	 <1347033467-3757-1-git-send-email-nicolas.dichtel@6wind.com>
	 <1347033467-3757-2-git-send-email-nicolas.dichtel@6wind.com>
	 <1347028510.2484.736.camel@edumazet-glaptop>  <504A09FD.1050201@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Nicolas Dichtel <nicolas.dichtel@6wind.com>, davem@davemloft.net,
	sri@us.ibm.com, linux-sctp@vger.kernel.org, netdev@vger.kernel.org
To: Vlad Yasevich <vyasevich@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:45690 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751394Ab2IGPIe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Sep 2012 11:08:34 -0400
In-Reply-To: <504A09FD.1050201@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2012-09-07 at 10:51 -0400, Vlad Yasevich wrote:

> I thought of that too, but that requires hacking xfrm to know the 
> namespace at the time it changes the flow_cache_genid.  This one seems 
> simpler to do.

Simpler maybe, but its yet another test done in fast path.
