From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH]: SCTP length validation.
Date: Mon, 23 Jun 2008 14:42:07 -0700 (PDT)
Message-ID: <20080623.144207.89110071.davem@davemloft.net>
References: <485D2467.7020300@hp.com>
	<20080622.123232.71141502.davem@davemloft.net>
	<485FC86F.4090808@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org
To: vladislav.yasevich@hp.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58044
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753193AbYFWVmH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 23 Jun 2008 17:42:07 -0400
In-Reply-To: <485FC86F.4090808@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vladislav.yasevich@hp.com>
Date: Mon, 23 Jun 2008 11:59:43 -0400

> David Miller wrote:
> > From: Vlad Yasevich <vladislav.yasevich@hp.com>
> > Date: Sat, 21 Jun 2008 11:55:19 -0400
> > 
> >> The same vulnerability also exists in sctp_getsockopt_peer_addrs_old().
> >> It's a bit more difficult to trigger since there is a dependency on
> >> the peer being multihomed as well, but it's still possible to cause the
> >> overwrite.
> > 
> > I can't see how that's possible.  This case looks harmless to
> > me.
> > 
> > The kernel side accesses are perfectly protected.  The kernel
> > will only access the actual address list stored via:
 ...
> 
> You are right.  I didn't look far enough.  Since there is no kmalloc(),
> the overflow of kernel memory is not possible, and copy_to_user should
> take care of any overflows of the user memory.

Thanks for double-checking my analysis Vlad.
