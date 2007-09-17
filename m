From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH][NETNS] Use list_for_each_entry_continue_reverse in
 setup_net
Date: Sun, 16 Sep 2007 17:07:00 -0700 (PDT)
Message-ID: <20070916.170700.116353255.davem@davemloft.net>
References: <20070914220714.3a1e87f8@oldman>
	<20070916.164914.15264075.davem@davemloft.net>
	<m1odg2w3yv.fsf@ebiederm.dsl.xmission.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@linux-foundation.org, xemul@openvz.org,
	netdev@vger.kernel.org, containers@lists.osdl.org,
	devel@openvz.org, dlezcano@fr.ibm.com
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48021
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752212AbXIQAHA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Sep 2007 20:07:00 -0400
In-Reply-To: <m1odg2w3yv.fsf@ebiederm.dsl.xmission.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Sun, 16 Sep 2007 18:06:00 -0600

> I did that audit when I replied to Stephen the first time and I just
> redid it to verify myself.  We are calling functions that can fail
> from the init function (kmalloc in the most common).  So the
> init function can fail.
> 
> So short of adding a bunch of BUG_ON's to the kernel to trap those
> failure cases we can't remove the backwards list walk.  Especially
> since I can initiate this code path as root by calling 
> "clone(CLONE_NEWNET...)".

I just noticed that posting and thanks for reiterating.
