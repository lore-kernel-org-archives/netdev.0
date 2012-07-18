From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: net-next and IPv6
Date: Wed, 18 Jul 2012 09:04:59 +0200
Message-ID: <1342595099.2626.1774.camel@edumazet-glaptop>
References: <20120717.061418.1893307699868826531.davem@davemloft.net>
	 <20120717.110314.1984735460095688066.davem@davemloft.net>
	 <1342587513.2626.1518.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f174.google.com ([209.85.220.174]:46328 "EHLO
	mail-vc0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752224Ab2GRHFG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 18 Jul 2012 03:05:06 -0400
Received: by vcbfk26 with SMTP id fk26so874869vcb.19
        for <netdev@vger.kernel.org>; Wed, 18 Jul 2012 00:05:06 -0700 (PDT)
In-Reply-To: <1342587513.2626.1518.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2012-07-18 at 06:58 +0200, Eric Dumazet wrote:
> IPv6 doesnt work anymore for me, at least TCP doesnt work
> 
> ssh ::1
> 
> ping6 is ok
> 
> tcpdump shows garbled source IP and ip-proto
> 
> 

Probable bug coming from

commit 35ad9b9cf7d8a2e6259a0d24022e910adb6f3489
Author: David S. Miller <davem@davemloft.net>
Date:   Mon Jul 16 03:44:56 2012 -0700

    ipv6: Add helper inet6_csk_update_pmtu().
    
    This is the ipv6 version of inet_csk_update_pmtu().
    
    Signed-off-by: David S. Miller <davem@davemloft.net>
