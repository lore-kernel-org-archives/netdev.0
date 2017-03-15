From: David Miller <davem@davemloft.net>
Subject: Re: [Bug 194723] connect() to localhost stalls after 4.9 -> 4.10
 upgrade
Date: Wed, 15 Mar 2017 15:30:17 -0700 (PDT)
Message-ID: <20170315.153017.1728029219325534654.davem@davemloft.net>
References: <20170315133619.64a31120@xeon-e3>
        <1489614034.28631.162.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: stephen@networkplumber.org, netdev@vger.kernel.org
To: eric.dumazet@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:55190 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750819AbdCOWaT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 15 Mar 2017 18:30:19 -0400
In-Reply-To: <1489614034.28631.162.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <eric.dumazet@gmail.com>
Date: Wed, 15 Mar 2017 14:40:34 -0700

> Finally time to get rid of buggy tw_recycle, that apparently some
> distros set to one.

It's not buggy, it's just not designed in a way that it can work in
the presence of NAT.

So yes, indeed, NO DISTRO SHOULD CHANGE THE VALUE TO "1" by default.

Is CentOS the only culprit?

But removing it is unnecessary, people who know what they are doing
can legitimately enable it if they know that there is no NAT going
on in their paths.
