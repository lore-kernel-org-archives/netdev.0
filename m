From: "Kevin Wilson" <Kevin.Wilson@comtrol.com>
Subject: RE: What was the reason for 2.6.22 SMP kernels to change how sendmsg is called?
Date: Thu, 13 Dec 2007 16:00:02 -0600
Message-ID: <B1F576FE19C55C43B8D2E31F061B50C04E60B2@exchange.comtrol.com>
References: <20071213.131753.156591181.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Cc: <netdev@vger.kernel.org>
To: "David Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exchange.comtrol.com ([204.73.219.163]:9043 "EHLO
	Exchange.comtrol.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933874AbXLMWAF convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 13 Dec 2007 17:00:05 -0500
Content-class: urn:content-classes:message
In-Reply-To: <20071213.131753.156591181.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I see your point but it just so happens it is a GPL'd driver, as is all of our Linux code we produce for our hardware. Granted it is out of tree, and after you saw it you would want it to stay that way. However, I would have sent you the whole thing if that is a pre-req to cordial exchanges on this list.

Nonetheless, a somewhat recent change in your tree, that I could not pinpoint on my own, caused the driver to stop functioning properly. So after much searching in git/google/sources with no luck, I decided to ask for a little assistance, maybe just a hint as to where the culprit may be in the tree so I could investigate for myself. For SNGs I tried the method that now works but I am still at a loss as to (can't find) what changes in the tree caused it to fail.

Does that now clarify/help matters any?

Regards,

Kevin

-----Original Message-----
From: David Miller [mailto:davem@davemloft.net]
Sent: Thursday, December 13, 2007 15:18
To: Kevin Wilson
Cc: netdev@vger.kernel.org
Subject: Re: What was the reason for 2.6.22 SMP kernels to change how
sendmsg is called?


From: "Kevin Wilson" <Kevin.Wilson@comtrol.com>
Date: Thu, 13 Dec 2007 14:54:31 -0600

> The 2nd method fixes the kernel oops I reported. Thanks to all those
> that assisted me (0) with my first post to this list (see below)
> ... uh, oh yeah, did I mention that number would tally up to ZERO
> people. ;-}

Because the knowledgable folks here have zero interest in helping
people with out-of-tree-likely-binary-only modules, because in such
cases you have our code but we don't have your's.

Have a nice day.
