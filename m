From: David Miller <davem@davemloft.net>
Subject: Re: [RFC Patch net-next] ipv6: do not allow ipv6 module to be
 removed
Date: Thu, 05 Sep 2013 14:06:04 -0400 (EDT)
Message-ID: <20130905.140604.2263717213507575570.davem@davemloft.net>
References: <1378285970-21404-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org,
	stephen@networkplumber.org
To: amwang@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:37119 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751625Ab3IESGN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Sep 2013 14:06:13 -0400
In-Reply-To: <1378285970-21404-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>
Date: Wed,  4 Sep 2013 17:12:50 +0800

> There was some bug report on ipv6 module removal path before.
> Also, as Stephen pointed out, after vxlan module gets ipv6 support,
> the ipv6 stub it used is not safe against this module removal either.
> So, let's just remove inet6_exit() so that ipv6 module will not be
> able to be unloaded.
> 
> Cc: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
> Cc: Stephen Hemminger <stephen@networkplumber.org>
> Cc: David S. Miller <davem@davemloft.net>
> Signed-off-by: Cong Wang <amwang@redhat.com>

I think we should make an effort to make ipv6 unloadable.  If you
believe little effort is being put into this now, even less will
be expended if I apply a patch like this one.

And this patch has a lot of problems, you aren't removing all of
the functions which will be completely unused.
