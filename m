From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [PATCH][CFT] Saner error handling in skb_copy_datagram_iter()
 et.al.
Date: Tue, 21 Feb 2017 13:25:03 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6DCFE6C974@AcuExch.aculab.com>
References: <20170212054209.GQ13195@ZenIV.linux.org.uk>
 <2337836.67BmyCWMtR@debian64> <20170214013306.GS13195@ZenIV.linux.org.uk>
 <20170217.105420.2167024053308682803.davem@davemloft.net>
 <20170217170315.GE29622@ZenIV.linux.org.uk>
 <20170218000214.GA19777@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "eric.dumazet@gmail.com" <eric.dumazet@gmail.com>,
        "rlwinm@sdf.org" <rlwinm@sdf.org>,
        "alexmcwhirter@triadic.us" <alexmcwhirter@triadic.us>,
        "chunkeey@googlemail.com" <chunkeey@googlemail.com>
To: 'Al Viro' <viro@ZenIV.linux.org.uk>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out4.electric.net ([192.162.216.193]:56779 "EHLO
        smtp-out4.electric.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752388AbdBUNZS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 21 Feb 2017 08:25:18 -0500
In-Reply-To: <20170218000214.GA19777@ZenIV.linux.org.uk>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Al Viro
> Sent: 18 February 2017 00:02
...
> Actually, I've a better solution.  Namely, analogue of iov_iter_advance()
> for going backwards.  The restriction is that you should never unroll
> further than where you've initially started *or* have the iovec, etc.
> array modified under you
...
> +void iov_iter_unroll(struct iov_iter *i, size_t unroll)
...

I'm sure there is a better name, maybe iov_iter_backup() ?

	David
