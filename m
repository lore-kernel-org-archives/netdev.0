From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [RFC PATCH net-2.6.24 0/3]: Attempt to fix lost_retrans brokeness
Date: Tue,  9 Oct 2007 15:19:59 +0300
Message-ID: <11919324023597-git-send-email-ilpo.jarvinen@helsinki.fi>
Cc: David Miller <davem@davemloft.net>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	TAKANO Ryousei <takano@axe-inc.co.jp>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:34987 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752439AbXJIMUD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Oct 2007 08:20:03 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Lost_retrans handling of sacktag was found to be flawed, two
problems that were found have an intertwined solution. Fastpath
problem has existed since hints got added and the other problem
has probably been there even longer than that. ...This change
may add non-trivial processing cost.

Initial sketch, only compile tested. This will become more and
more useful, when sacktag starts to process less and less skbs,
which hopefully happens quite soon... :-) Sadly enough it will
probably then be consuming part of the benefits we're able to
achieve by less skb walking...

First one is trivial, so Dave might want to apply it already.

--
 i.


