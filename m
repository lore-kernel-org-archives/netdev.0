From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netns: Only route multicast trafic in init_net
Date: Mon, 14 Jul 2008 22:25:53 -0700 (PDT)
Message-ID: <20080714.222553.228256571.davem@davemloft.net>
References: <m1od54dwar.fsf@frodo.ebiederm.org>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ebiederm@xmission.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37749
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1752814AbYGOFZw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jul 2008 01:25:52 -0400
In-Reply-To: <m1od54dwar.fsf@frodo.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: ebiederm@xmission.com (Eric W. Biederman)
Date: Fri, 11 Jul 2008 13:02:04 -0700

> 
> Currently the code to only support multicast traffic in the initial
> namespace is incomplete, and receiving a multicast packet causes in a
> network namespace causes us to take an initialized lock.  Resulting
> in a nasty oops. Ouch!
> 
> So until we have network namespace support in igmp.c simply disable
> multicast packet reception.
> 
> Signed-off-by: Eric W. Biederman <ebiederm@xmission.com>

Grumble...

So you send me a patch later which depended upon these ones and yet
you made no mention of this dependency.

Can you just resend me whatever I should add right now?

Thanks.
