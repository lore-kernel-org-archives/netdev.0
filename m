From: Andi Kleen <ak@suse.de>
Subject: SIOCGIFCOUNT
Date: Sat, 21 Apr 2007 00:04:51 +0200
Message-ID: <200704210004.51278.ak@suse.de>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.suse.de ([195.135.220.2]:54518 "EHLO mx1.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1767284AbXDTWE4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 20 Apr 2007 18:04:56 -0400
Received: from Relay1.suse.de (mail2.suse.de [195.135.221.8])
	(using TLSv1 with cipher DHE-RSA-AES256-SHA (256/256 bits))
	(No client certificate requested)
	by mx1.suse.de (Postfix) with ESMTP id 24835122EC
	for <netdev@vger.kernel.org>; Sat, 21 Apr 2007 00:04:55 +0200 (CEST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



Hi,

A recent 32bit jdk spews these messages on x86-64

ioctl32(java:3877): Unknown cmd fd(3) cmd(00008938){00} arg(bfa4c844) on socket:[4470216]
..

0x8938 is SIOCGIFCOUNT. As far as I can see it is only defined in sockios.h, but not 
implemented?

Should it be removed from the include file or implemented?

I probably will add a dummy compat ioctl entry to shut the JDK up at least.

-Andi




 
