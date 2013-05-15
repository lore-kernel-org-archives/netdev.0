From: Denys Fedoryshchenko <denys@visp.net.lb>
Subject: Re: [PATCH] net/802/mrp: fix lockdep splat
Date: Wed, 15 May 2013 17:50:40 +0300
Message-ID: <1851d9143b2404f6686cf25d6bcea823@visp.net.lb>
References: <6901a7785249816fe13a98e3c0b35127@visp.net.lb>
 <1368447851.13473.119.camel@edumazet-glaptop>
 <16b0a5ee4602cb9005dd67ea7ad0d4e8@visp.net.lb>
 <20130514.120754.1745967383330029903.davem@davemloft.net>
 <1368559307.4519.21.camel@edumazet-glaptop>
 <1368560401.4519.25.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, amwang@redhat.com,
	david.ward@ll.mit.edu, hayeswang@realtek.com, romieu@fr.zoreil.com,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hosting.visp.net.lb ([194.146.153.11]:51991 "EHLO
	hosting.visp.net.lb" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759261Ab3EOOum (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 May 2013 10:50:42 -0400
In-Reply-To: <1368560401.4519.25.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2013-05-14 22:40, Eric Dumazet wrote:
> 
> I definitely could trigger the bug easily without my patch :


> 
> And with the patch, there is no lockdep splat anymore.
> 
> Tested-by: Eric Dumazet <edumazet@google.com>

Yes, it seems after depclean i cannot reproduce anymore this bug. My 
bad, seems i should recompile kernel completely next time.

---
Denys Fedoryshchenko, Network Engineer, Virtual ISP S.A.L.
