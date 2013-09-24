From: David Miller <davem@redhat.com>
Subject: Re: [PATCH net-next] ipv6: do not allow ipv6 module to be removed
Date: Tue, 24 Sep 2013 11:32:44 -0400 (EDT)
Message-ID: <20130924.113244.2190163840105995129.davem@redhat.com>
References: <1379733141-10643-1-git-send-email-amwang@redhat.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org,
	stephen@networkplumber.org
To: amwang@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:27607 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751301Ab3IXPcz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 24 Sep 2013 11:32:55 -0400
In-Reply-To: <1379733141-10643-1-git-send-email-amwang@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Cong Wang <amwang@redhat.com>
Date: Sat, 21 Sep 2013 11:12:21 +0800

> From: Cong Wang <amwang@redhat.com>
> 
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

Fair enough, applied.  We can always revert this later if we ever
make ipv6 properly unloadable.
