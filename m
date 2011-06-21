From: Herton Ronaldo Krzesinski <herton.krzesinski@canonical.com>
Subject: Reported regression against commit a05d2ad
Date: Tue, 21 Jun 2011 17:15:29 -0300
Message-ID: <20110621201528.GB2249@herton-IdeaPad-Y430>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: lamont@canonical.com, sconklin@canonical.com,
	tim.gardner@canonical.com, netdev@vger.kernel.org
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from adelie.canonical.com ([91.189.90.139]:52739 "EHLO
	adelie.canonical.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750863Ab1FUUPe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jun 2011 16:15:34 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

after update to one of the latest 2.6.32.x stable kernels for Ubuntu, we
got a regression report about timeout in tcp connections
(https://launchpad.net/bugs/791512).

We tried help reporter with a bisect process, but it was taking some
time, so we reverted some suspect commits, until we isolated it to
commit "af_unix: Only allow recv on connected seqpacket sockets."

With only commit a05d2ad reverted, testing results so far indicate the
issue doesn't happen.

I'm unfamiliar with unix sockets code, so can't see at first why this
commit in particular is causing problems, for now I can only say may be
something at application level using unix sockets regressed with it (?).
I'm just reporting it right now, and we plan to revert it for that kernel
until more info is found about it.

I'm adding reporter to CC (Lamont), in case more details are necessary
etc.

-- 
[]'s
Herton
