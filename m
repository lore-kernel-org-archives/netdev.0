From: Stefano Brivio <sbrivio@redhat.com>
Subject: Re: [PATCH] ipv6: fix net.ipv6.conf.all.accept_dad behaviour for
 real
Date: Fri, 6 Oct 2017 01:27:55 +0200
Message-ID: <20171006012755.33d70662@elisabeth>
References: <20171005170305.30065-1-mcroce@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Matteo Croce <mcroce@redhat.com>, Erik Kline <ek@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:59400 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751083AbdJEX2C (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 5 Oct 2017 19:28:02 -0400
In-Reply-To: <20171005170305.30065-1-mcroce@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu,  5 Oct 2017 19:03:05 +0200
Matteo Croce <mcroce@redhat.com> wrote:

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

This was actually:

Reported-by: Erik Kline <ek@google.com>


-- 
Stefano
