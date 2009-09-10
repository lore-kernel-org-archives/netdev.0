From: Pekka Savola <pekkas@netcore.fi>
Subject: radvd 1.5 released
Date: Thu, 10 Sep 2009 15:00:51 +0300 (EEST)
Message-ID: <alpine.LRH.2.00.0909101457470.16704@netcore.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
To: netdev@vger.kernel.org, radvd-announce-l@litech.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from netcore.fi ([193.94.160.1]:44286 "EHLO netcore.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752260AbZIJMLX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 10 Sep 2009 08:11:23 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

A new version of radvd has been released.  This fixes two regressions 
introduced a couple of years back: radvd might end up segfaulting or 
infinite looping if cable is plugged on/off, or if the cable is off 
when starting and IgnoreIfMissing is configured, the interface might 
continue being ignored.

Special thanks to Reuben Hawkins and Teemu Torma for debugging 
these problems and working on patches.

Get it at: http://www.litech.org/radvd/

-- 
Pekka Savola                 "You each name yourselves king, yet the
Netcore Oy                    kingdom bleeds."
Systems. Networks. Security. -- George R.R. Martin: A Clash of Kings

