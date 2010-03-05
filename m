From: Pekka Savola <pekkas@netcore.fi>
Subject: radvd 1.6 released
Date: Fri, 5 Mar 2010 14:28:28 +0200 (EET)
Message-ID: <alpine.LRH.2.00.1003051425590.26086@netcore.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
To: netdev@vger.kernel.org, radvd-announce-l@litech.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from netcore.fi ([193.94.160.1]:49333 "EHLO netcore.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750816Ab0CEM2g (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 5 Mar 2010 07:28:36 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

A new version of radvd has been released.  This contains a couple of 
bug fixes and some new functionality.  Thanks to everyone who 
contributed patches (below).

     *  Decrease MSG_SIZE from 4096 to about 1500B. Send buffer uses a 
smaller size in order to avoid sending out fragmented packets, yet 
being able to receive full-size frames.
     * Keep track of buffer size and exit if the number of 
prefixes/routes/etc. would grow too much. Prevent a memory corruption 
due to wrong memset. Patches from Jan Gorig, Red Hat bug #554125.
     * On BSD use getifaddrs() also in setup_deviceinfo(), fixes a 
multiple interfaces problem on NetBSD 5 due to change in data 
structures. Patch from Michael Stapelberg.
     * Allow radvd.conf prefix, clients, route, and RDNSS options to be 
in any order. Patch from Michael Stapelberg.

Get it at: http://www.litech.org/radvd/

-- 
Pekka Savola                 "You each name yourselves king, yet the
Netcore Oy                    kingdom bleeds."
Systems. Networks. Security. -- George R.R. Martin: A Clash of Kings
