From: Jeremy Fitzhardinge <jeremy@goop.org>
Subject: Xen netfront fixes for changed skbuff in net-2.6.22.git
Date: Wed, 28 Mar 2007 11:36:17 -0700
Message-ID: <460AB5A1.1000807@goop.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Xen-devel <xen-devel@lists.xensource.com>,
	NetDev <netdev@vger.kernel.org>,
	Chris Wright <chrisw@sous-sol.org>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw.goop.org ([64.81.55.164]:49635 "EHLO mail.goop.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965573AbXC1SgO (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Mar 2007 14:36:14 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Herbert,

I wonder if you've got a chance to look at netfront in light of the new
stuff in davem's network tree  (the stuff that's in
http://git.kernel.org/?p=linux/kernel/git/davem/net-2.6.22.git).

In particular, struct sk_buff has been changed so that "nh" has gone,
and the replacement can be just an offset rather than a full pointer. 
This breaks the netfront because it tries to stash a page * in nh.raw. 
I had a quick look at it and couldn't see an easy fix, but I don't
really understand what's going on in there.

But you do.  Any chance you could have a look at it, and at least give
me some pointers about how to proceed?

Thanks,
    J
