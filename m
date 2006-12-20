From: Pekka Savola <pekkas@netcore.fi>
Subject: ND unsolicited NAs when address is added?
Date: Wed, 20 Dec 2006 12:22:56 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0612201213530.22453@netcore.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Return-path: <netdev-owner@vger.kernel.org>
Received: from netcore.fi ([193.94.160.1]:60024 "EHLO netcore.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932749AbWLTKgZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 20 Dec 2006 05:36:25 -0500
Received: from localhost (pekkas@localhost)
	by netcore.fi (8.12.11.20060614/8.12.11) with ESMTP id kBKAMuA3022621
	for <netdev@vger.kernel.org>; Wed, 20 Dec 2006 12:22:56 +0200
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

RFC2461 specifies in section 7.2.6 that a host may send unsolicited 
NA(s) for example when its link layer address changes or IP address is 
added to inform the neighbors that their ND cache may need to be 
updated.

Some current routers (probably) erroneously depend on this to reduce 
the "downtime" if an IP address is moved from one host to another 
(otherwise they'll continue to forward packets to the old link-layer 
address until their ND cache timeouts).

I tested this behaviour on Linux 2.6.18 and FreeBSD 6.2 and neither 
sends these unsolicited NAs when an IP address is configured.  Is 
there a reason not to add this optimization?

-- 
Pekka Savola                 "You each name yourselves king, yet the
Netcore Oy                    kingdom bleeds."
Systems. Networks. Security. -- George R.R. Martin: A Clash of Kings
