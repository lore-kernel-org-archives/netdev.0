From: "=?utf-8?q?Ilpo_J=C3=A4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH net-2.6.25 0/8] [NET]: More uninlining & related
Date: Sat, 12 Jan 2008 11:34:21 +0200
Message-ID: <12001304691600-git-send-email-ilpo.jarvinen@helsinki.fi>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:35759 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756419AbYALJeg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Jan 2008 04:34:36 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Dave,

First of all, I changed output encoding of git to utf-8, so I
guess the encoding should not cause the same trouble for you.

Here are couple of more to uninline things. Pretty
straightforward except the EXPORT_SYMBOLs, I've no idea which
is the right variant (feel free to fix them while applying :-)).
Also pktgen uninlining is somewhat questionable because it's
just a testing tool so feel free to drop it if it feels
unnecessary (I could have asked first but it's just as easy to
do it this way if not easier)...

There were more dead static inlines found after inlines removed
(gcc didn't report them otherwise) than in pktgen now included,
but I'm not sure if I should send "by default" patches removing
or #if 0'ing them?


--
 i.



