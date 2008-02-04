From: Pekka Savola <pekkas@netcore.fi>
Subject: radvd 1.1 released
Date: Mon, 4 Feb 2008 08:55:12 +0200 (EET)
Message-ID: <alpine.LRH.1.00.0802040849370.19987@netcore.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: radvd-devel-l@litech.org
To: netdev@vger.kernel.org, radvd-announce-l@litech.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from netcore.fi ([193.94.160.1]:49807 "EHLO netcore.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753154AbYBDHY6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Feb 2008 02:24:58 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

A new version of radvd has been released.  There have been a couple of 
new features.

Interfaces must now be RUNNING, not just UP, to be considered by 
default radvd configuration.  This is because nowadays kernels no 
longer generate v6 link-local addresses if the interface is just UP, 
in contrast to e.g., what earlier kernels did.

I'd like issue special thanks to Jim Paris for all the patches he has 
sent :-).

Get it at: http://www.litech.org/radvd/

Changes since 1.0:
     *  Implement privilege separation on Linux: a master root process 
(which is able to reconfigure interfaces) and the main process. There 
is '-s' toggle to keep old behaviour.
     * Fix Linux retrans_timer on old kernels (newer ones have 
retrans_timer_ms)
     * Fix stderr+syslog (default) logging on non-i386 platforms.
     * Require that interface must be RUNNING instead of just UP. Note: 
this could break deployments with very old kernels.
     * Implement automatic interface address advertising with special 
prefix ::/64.
     * Relax interface naming (e.g. with VLANs) requirements.
     * Fix ordering of route, prefix and RDNSS options (only matters 
with RDNSS)

--
Pekka Savola                 "You each name yourselves king, yet the
Netcore Oy                    kingdom bleeds."
Systems. Networks. Security. -- George R.R. Martin: A Clash of Kings
