From: Sabrina Dubroca <sd@queasysnail.net>
Subject: Re: [PATCH net] ipv4: Don't override return code from
 ip_route_input_noref()
Date: Fri, 1 Sep 2017 01:45:06 +0200
Message-ID: <20170831234506.GA1838@bistromath.localdomain>
References: <c4d8970306e614ac139cf2f33ab5e6bb73b30154.1504194307.git.sbrivio@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: "David S . Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
        Wei Wang <weiwan@google.com>
To: Stefano Brivio <sbrivio@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53406 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751618AbdHaXpK (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 31 Aug 2017 19:45:10 -0400
Content-Disposition: inline
In-Reply-To: <c4d8970306e614ac139cf2f33ab5e6bb73b30154.1504194307.git.sbrivio@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2017-08-31, 18:11:41 +0200, Stefano Brivio wrote:
> After ip_route_input() calls ip_route_input_noref(), another
> check on skb_dst() is done, but if this fails, we shouldn't
> override the return code from ip_route_input_noref(), as it
> could have been more specific (i.e. -EHOSTUNREACH).
> 
> This also saves one call to skb_dst_force_safe() and one to
> skb_dst() in case the ip_route_input_noref() check fails.
> 
> Reported-by: Sabrina Dubroca <sdubroca@redhat.com>
> Fixes: ad65a2f05695 ("ipv4: call dst_hold_safe() properly")

That should be instead:

Fixes: 9df16efadd2a ("ipv4: call dst_hold_safe() properly")

Acked-by: Sabrina Dubroca <sd@queasysnail.net>

-- 
Sabrina
