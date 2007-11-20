From: David Miller <davem@davemloft.net>
Subject: handling bugs...
Date: Tue, 20 Nov 2007 04:41:19 -0800 (PST)
Message-ID: <20071120.044119.45485900.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: linux-wireless@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46710
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756037AbXKTMlU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 20 Nov 2007 07:41:20 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


Some of you wireless guys should really be ashamed of yourselves how
you handled the zd1211rw bugs reported by the sparc64 user.

Instead of helping the user work towards getting a working setup,
analyzing their bug and presenting test patches for the user to try,
all of you passed the buck around.

That completely sucks.  In fact it sucks so much that there are no
words to describe it.

In 35 minutes of casual code reading and looking at his initial report
email I was able to figure out all of the problems.  One of which was
a rather awful userland corruption bug that hits every 64-bit
platform.

I don't even have that person's hardware and I was able to figure it
out.  I promise, you will not die if you read some code and write some
test patches for the user to try.

I never ever want to see that kind of crap happen again.

Thank you.
