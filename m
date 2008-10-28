From: Pekka Savola <pekkas@netcore.fi>
Subject: radvd 1.2 released
Date: Tue, 28 Oct 2008 18:57:01 +0200 (EET)
Message-ID: <alpine.LRH.2.00.0810281851460.12691@netcore.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
Cc: radvd-devel-l@litech.org
To: netdev@vger.kernel.org, radvd-announce-l@litech.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from netcore.fi ([193.94.160.1]:60634 "EHLO netcore.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751594AbYJ1Q5N (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Oct 2008 12:57:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

A new version of radvd has been released.  This is a maintenance 
release that provides minor changes and patch integration.

Get it at: http://www.litech.org/radvd/

     * Accept virtually any kind of interface naming convention.
     * If stale radvd.pid exists, try to overwrite it unless the
       specified PID exists.
     * Define _GNU_SOURCE to fix compilation with glibc >= 2.8.
     * Remove -Wconversion from default CFLAGS due to bogus warnings,
       fix some real warnings.
     * Decrease the default preferred lifetimes from 30/1 days to
       1d/4h.

-- 
Pekka Savola                 "You each name yourselves king, yet the
Netcore Oy                    kingdom bleeds."
Systems. Networks. Security. -- George R.R. Martin: A Clash of Kings
