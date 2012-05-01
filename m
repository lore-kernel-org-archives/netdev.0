From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: 3.4-rc: NETDEV WATCHDOG: eth0 (r8169): transmit queue 0 timed out
Date: Tue, 1 May 2012 19:27:48 +0200
Message-ID: <20120501172748.GA17117@electric-eye.fr.zoreil.com>
References: <20120501182405.3dda59b9@stein>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org
To: Stefan Richter <stefanr@s5r6.in-berlin.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:42183 "EHLO violet"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1757235Ab2EARdf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 May 2012 13:33:35 -0400
Content-Disposition: inline
In-Reply-To: <20120501182405.3dda59b9@stein>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Stefan Richter <stefanr@s5r6.in-berlin.de> :
[...]
> I switched from 3.3 to 3.4-rc5 yesterday and am getting the following warning
> some time after boot (e.g. this time about two hours after boot).  What's up
> with that?

The device stopped being able to transmit anything at some point (netdev
watchdog message). The warnings always look the same. If the device does
not recover, we have a problem. Do we ?

[...]
> There are no noticeable issues, but I don't run anything demanding on the
> interface right now which would make any downtime obvious.

I don't understand: is it a low traffic interface or a no traffic one ?

> It is an RTL8168(?) on an Asus M3A78-EM motherboard.

dmesg | grep XID should identify the chipset. You may consider sending
an 'ethtool eth0' and 'ethtool -i eth0'.

-- 
Ueimor
