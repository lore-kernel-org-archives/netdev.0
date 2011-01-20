From: Pekka Savola <pekkas@netcore.fi>
Subject: radvd 1.7 released
Date: Thu, 20 Jan 2011 09:37:46 +0200 (EET)
Message-ID: <alpine.LRH.2.02.1101200937320.9926@netcore.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII; format=flowed
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from netcore.fi ([193.94.160.1]:35550 "EHLO netcore.fi"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751521Ab1ATIS6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 20 Jan 2011 03:18:58 -0500
Received: from netcore.fi (localhost [127.0.0.1])
	by netcore.fi (8.13.8/8.13.8) with ESMTP id p0K7bknt010092
	(version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
	for <netdev@vger.kernel.org>; Thu, 20 Jan 2011 09:37:46 +0200
Received: from localhost (pekkas@localhost)
	by netcore.fi (8.13.8/8.13.8/Submit) with ESMTP id p0K7bknh010089
	for <netdev@vger.kernel.org>; Thu, 20 Jan 2011 09:37:46 +0200
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

Radvd 1.7 has been released on Jan 12.  Most important changes:

      * Fix radvd skipping multiple interfaces when UnicastOnly is on or
        AdvSendAdvert is off. This got broken in radvd 1.3. Patch from
        Cedric BAIL.
      * Fix a segmentation fault on reload_config() timer list
        corruption that only occurs with multiple interfaces.
      * Add '-c' flag to test configuration.
      * Deprecate old, pre-RFC5006 parameters. Support RFC6106 by adding
        DNS Search List support. From Pierre Ossman.
      * AdvSourceLLAddress fixed on FreeBSD when link layer token length
        is zero.
      * Welcome new co-maintainer: Reuben Hawkins

Get it from: http://www.litech.org/radvd/

-- 
Pekka Savola                 "You each name yourselves king, yet the
Netcore Oy                    kingdom bleeds."
Systems. Networks. Security. -- George R.R. Martin: A Clash of Kings

