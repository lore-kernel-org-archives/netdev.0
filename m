From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH net-2.6.24 0/9]: TCP improvements & cleanups
Date: Thu, 20 Sep 2007 15:17:43 +0300
Message-ID: <11902906724088-git-send-email-ilpo.jarvinen@helsinki.fi>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:39950 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752042AbXITMRy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Sep 2007 08:17:54 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Dave,

Just in case you're short on what to do ;-) here are some TCP
related cleanups & improvements to net-2.6.24. Including FRTO
undo fix which finally should allow FRTO to be turned on, and
some simple fastpath tweaks simple enough to the 2.6.24
schedule. ...I've a larger fastpath_hint removal patch coming
up later too but it's really a monster which needs more time
though I guess it could really cut down the SACK processing
latencies people are experience with high-speed flows (I'll
probably post it with RFC once you've picked these up).

These were boot (& couple of hours) tested on the top of
net-2.6.24 (something after the first "large" rebase you did,
so you could count that as success report of it too :-)).
Not sure if all those fragment/collapse paths I modified got
executed though.

--
 i.


