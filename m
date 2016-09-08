From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: [PATCH net-next] net: xfrm: Change u32 sysctl entries to use
 proc_douintvec
Date: Thu, 8 Sep 2016 07:51:17 +0200
Message-ID: <20160908055117.GM31137@gauss.secunet.com>
References: <1473206971-20131-1-git-send-email-subashab@codeaurora.org>
 <20160907.172518.871134561524524971.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <subashab@codeaurora.org>, <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([62.96.220.36]:36358 "EHLO a.mx.secunet.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1756378AbcIHGv0 (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 8 Sep 2016 02:51:26 -0400
Content-Disposition: inline
In-Reply-To: <20160907.172518.871134561524524971.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Sep 07, 2016 at 05:25:18PM -0700, David Miller wrote:
> From: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
> Date: Tue,  6 Sep 2016 18:09:31 -0600
> 
> > proc_dointvec limits the values to INT_MAX in u32 sysctl entries.
> > proc_douintvec allows to write upto UINT_MAX.
> > 
> > Signed-off-by: Subash Abhinov Kasiviswanathan <subashab@codeaurora.org>
> 
> I am assuming Steffen will pick this up.

proc_douintvec is not in the ipsec-next tree. The ipsec-next
tree is currently based on net-next from Aug 9. The patch
that introduces proc_douintvec came in on Aug 25.

I can take it after the pull request for ipsec-next, that
I plan to do today. Alternatively, you can take it directly
into net-next. It does not interfere anything that I
have in ipsec-next. In case you want to take it directly:

Acked-by: Steffen Klassert <steffen.klassert@secunet.com>
