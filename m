From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [RFC PATCH net-2.6.25 0/10] [TCP]: Cleanups, tweaks & sacktag recode
Date: Thu, 15 Nov 2007 15:37:24 +0200
Message-ID: <11951338542267-git-send-email-ilpo.jarvinen@helsinki.fi>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:45931 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756756AbXKONhg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Nov 2007 08:37:36 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave,

Here's the sacktag recv_sack_cache usage rewrite which you were
interested to look at earlier, due to other fixes it has dragged
on this long... Besides that, couple of new bugs^W^Wcleanups &
tweaks are there as well :-). I'll probably have to summon create
tcp_sacktag_state patch back to avoid all that pointer passing
all-around. But those won't be earth-shattering changes. The first
two are probably trivial enough to be accepted as is.

Boot & simple transfer tested, minor fixes after that. I'll try
to arrange time at some point of time to do more verification for
the new sacktag and rfc3517 code, and compare old and new sacktag
to get some numbers from accessed skbs per sacktag operation.

--
 i.


