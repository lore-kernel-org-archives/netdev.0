From: Pekka Savola <pekkas@netcore.fi>
Subject: radvd 1.0 released
Date: Wed, 1 Nov 2006 17:23:46 +0200 (EET)
Message-ID: <Pine.LNX.4.64.0611011720510.20570@netcore.fi>
Reply-To: radvd-devel-l@litech.org
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: radvd-devel-l@litech.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from netcore.fi ([193.94.160.1]:18154 "EHLO netcore.fi")
	by vger.kernel.org with ESMTP id S1946896AbWKAPXv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Nov 2006 10:23:51 -0500
To: netdev@vger.kernel.org, radvd-announce-l@litech.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

A new version of radvd has been released.  There hasn't been any very 
major changes, just regular maintenance and a one new experimental 
feature (RDNSS option).

Get it at: http://www.litech.org/radvd/

Changes since 0.9.1:
    * Fix AdvDefaultLifetime initalization, broken in 0.9.1.
    * Fix STDERR+syslog logging, don't try STDERR after forking.
    * Implement RDNSS draft with (non-allocated) ND type code 25.
    * Redefined IgnoreIfMissing: failed interfaces are now 
      reinitialized by default. IgnoreIfMissing only omits warnings 
      about these.
    * Unblock SIGALRM at startup.
    * Implement MAX_INITIAL_RTR_ADVERT_INTERVAL handling.
    * Perform some dynamic/static code audit, fix some minor bugs and 
      do cleanup as a result.

-- 
Pekka Savola                 "You each name yourselves king, yet the
Netcore Oy                    kingdom bleeds."
Systems. Networks. Security. -- George R.R. Martin: A Clash of Kings
