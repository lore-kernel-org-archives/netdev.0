From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [RFC PATCH net-2.6] TCP: SACKtag rewrite
Date: Thu, 11 Oct 2007 15:21:52 +0300
Message-ID: <11921053182989-git-send-email-ilpo.jarvinen@helsinki.fi>
Cc: netdev@vger.kernel.org, TAKANO Ryousei <takano@axe-inc.co.jp>,
	--cc@cs.helsinki.fi
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:60931 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753321AbXJKMWA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Oct 2007 08:22:00 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dave (& others?),

Here's the rebased SACKtag rewrite series rebased for you,
applies on top of the seven patch series I sent earlier
today (or on top of net-2.6 as soon as Dave picks them up
and pushes out).

Some trivial helper patches first (two first ones from
tcp-2.6), the most interesting bits are in the fifth patch.

I'll recode the included DSACK handling, it will be much
cleaner then so please ignore that mess for now...

This time only compile tested but should be still runnable
because I tested an earlier version and diff against that
looked sane.

-- 
 i.



