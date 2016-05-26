From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] Accept user specified MTU value when create new vxlan
 link
Date: Thu, 26 May 2016 12:34:36 -0700 (PDT)
Message-ID: <20160526.123436.1240760291714449988.davem@davemloft.net>
References: <1464253741-6021-1-git-send-email-oc@yunify.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, trivial@kernel.org
To: oc@yunify.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:53769 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751346AbcEZTei (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 May 2016 15:34:38 -0400
In-Reply-To: <1464253741-6021-1-git-send-email-oc@yunify.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Chen Haiquan <oc@yunify.com>
Date: Thu, 26 May 2016 17:09:01 +0800

> Fixes: 0dfbdf4102b9303d3ddf2177c0220098ff99f6de
> (vxlan: Factor out device configuration) which missed MTU value specified
> by user when create new vxlan link.
> 
> Signed-off-by:  Chen Haiquan <oc@yunify.com>

This is not a properly formatted patch submission.

First of all, your Subject line should have a proper subsystem prefix
specified.  That way people who scan the GIT shortlog can tell where
your change is taking place by scanning the beginning of every commit
header line.

	[PATCH] vxlan: Use specified MTU value when creating new link.

Second, your Fixes tag is not the place where you explain the problem
and how you are fixing it.

You put that in the commit message proper, then you give the Fixes:
tag.

Have you looked at how other people format their commit messages?
Have you seen anyone else do things the way you have done so here?
Always mimick other patch submitters, and learn by example.  If you
still can't figure out how to format something properly, ask the
list.

Thanks.
