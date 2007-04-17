From: David Miller <davem@davemloft.net>
Subject: Re: [Bugme-new] [Bug 8320] New: replacing route in kernel doesn't
 send netlink message
Date: Mon, 16 Apr 2007 17:10:16 -0700 (PDT)
Message-ID: <20070416.171016.43503207.davem@davemloft.net>
References: <461D26CB.3010508@trash.net>
	<1176400428.24446.40.camel@nt.wq.cz>
	<4623029A.2090906@trash.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: milon@wq.cz, akpm@linux-foundation.org, netdev@vger.kernel.org,
	bugme-daemon@bugzilla.kernel.org
To: kaber@trash.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:37396
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1754088AbXDQAKQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Apr 2007 20:10:16 -0400
In-Reply-To: <4623029A.2090906@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Patrick McHardy <kaber@trash.net>
Date: Mon, 16 Apr 2007 06:59:06 +0200

> RTM_DELROUTE + RTM_NEWROUTE seem to be safer, although you're correct
> that it might cause userspace to perform some action upon receiving
> the DELROUTE message since the update is non-atomic. So I really don't
> know, I'm in favour of having notifications for replacements, but I
> fear we might break something.

We can cry foul about a broken application if an application following
the API correctly would interpret the new messages correctly.

I think it doesn't make sense to do a delete then a newroute for
the atomicity issues, and therefore the replace makes the most
sense as long as existing correct uses of the API would not
explode on this.
