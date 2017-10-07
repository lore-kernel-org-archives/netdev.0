From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ipv6: fix net.ipv6.conf.all.accept_dad behaviour for
 real
Date: Sat, 07 Oct 2017 23:11:59 +0100 (WEST)
Message-ID: <20171007.231159.210016932080491947.davem@davemloft.net>
References: <20171005170305.30065-1-mcroce@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ek@google.com
To: mcroce@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42870 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751940AbdJGWMQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 7 Oct 2017 18:12:16 -0400
In-Reply-To: <20171005170305.30065-1-mcroce@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Matteo Croce <mcroce@redhat.com>
Date: Thu,  5 Oct 2017 19:03:05 +0200

> Commit 35e015e1f577 ("ipv6: fix net.ipv6.conf.all interface DAD handlers")
> was intended to affect accept_dad flag handling in such a way that
> DAD operation and mode on a given interface would be selected
> according to the maximum value of conf/{all,interface}/accept_dad.
> 
> However, addrconf_dad_begin() checks for particular cases in which we
> need to skip DAD, and this check was modified in the wrong way.
> 
> Namely, it was modified so that, if the accept_dad flag is 0 for the
> given interface *or* for all interfaces, DAD would be skipped.
> 
> We have instead to skip DAD if accept_dad is 0 for the given interface
> *and* for all interfaces.
> 
> Fixes: 35e015e1f577 ("ipv6: fix net.ipv6.conf.all interface DAD handlers")
> Acked-by: Stefano Brivio <sbrivio@redhat.com>
> Signed-off-by: Matteo Croce <mcroce@redhat.com>

Applied.
