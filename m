From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net: more accurate network taps in transmit
 path
Date: Wed, 19 Sep 2012 20:21:12 +0200
Message-ID: <1348078872.26523.1233.camel@edumazet-glaptop>
References: <20120918211423.GA19115@darkstar>
	 <1348034050.26523.325.camel@edumazet-glaptop>
	 <1348037089.26523.397.camel@edumazet-glaptop>
	 <20120919.141637.531173978256020103.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: jamie.gloudon@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:46623 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753531Ab2ISSVR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Sep 2012 14:21:17 -0400
Received: by bkwj10 with SMTP id j10so706088bkw.19
        for <netdev@vger.kernel.org>; Wed, 19 Sep 2012 11:21:16 -0700 (PDT)
In-Reply-To: <20120919.141637.531173978256020103.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-09-19 at 14:16 -0400, David Miller wrote:

> Are you really sure that all the network tap implementations can
> handle software GSO segmented skbs using skb->next linkage?
> 
> Because that is what they can potentially see after this change.

I dont think so, because skb->next is NULL at the points I call the
network tap.

Or did I miss something ?
