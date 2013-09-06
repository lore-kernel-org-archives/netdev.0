From: Cong Wang <amwang@redhat.com>
Subject: Re: [RFC Patch net-next] ipv6: do not allow ipv6 module to be
 removed
Date: Fri, 06 Sep 2013 10:52:51 +0800
Message-ID: <1378435971.969.6.camel@cr0>
References: <1378285970-21404-1-git-send-email-amwang@redhat.com>
	 <20130905.140604.2263717213507575570.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, yoshfuji@linux-ipv6.org,
	stephen@networkplumber.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51067 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753774Ab3IFCxK (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 Sep 2013 22:53:10 -0400
In-Reply-To: <20130905.140604.2263717213507575570.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-09-05 at 14:06 -0400, David Miller wrote:
> From: Cong Wang <amwang@redhat.com>
> Date: Wed,  4 Sep 2013 17:12:50 +0800
> 
> > There was some bug report on ipv6 module removal path before.
> > Also, as Stephen pointed out, after vxlan module gets ipv6 support,
> > the ipv6 stub it used is not safe against this module removal either.
> > So, let's just remove inet6_exit() so that ipv6 module will not be
> > able to be unloaded.
> > 
> > Cc: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
> > Cc: Stephen Hemminger <stephen@networkplumber.org>
> > Cc: David S. Miller <davem@davemloft.net>
> > Signed-off-by: Cong Wang <amwang@redhat.com>
> 
> I think we should make an effort to make ipv6 unloadable.  If you
> believe little effort is being put into this now, even less will
> be expended if I apply a patch like this one.
> 
> And this patch has a lot of problems, you aren't removing all of
> the functions which will be completely unused.

They are still used in the cleanup path of inet6_init() as well, can't
be removed completely.

Thanks!
