From: Tino Keitel <tino.keitel@tikei.de>
Subject: Re: Regression: Wake on LAN doesn't work in sky2 with
 2.6.33-rc4-git2
Date: Mon, 18 Jan 2010 09:37:58 +0100
Message-ID: <20100118083757.GA2619@mac.home>
References: <20100115091053.GA5477@mac.home>
 <201001152323.37718.rjw@sisk.pl>
 <20100117231932.GA5504@mac.home>
 <201001180136.45823.rjw@sisk.pl>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Stephen Hemminger <shemminger@vyatta.com>
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eazy.amigager.de ([213.239.192.238]:41785 "EHLO
	eazy.amigager.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752088Ab0ARIiE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Jan 2010 03:38:04 -0500
Received: from mac.home (port-92-206-67-99.dynamic.qsc.de [92.206.67.99])
	by eazy.amigager.de (Postfix) with ESMTPA id 96776F48052
	for <netdev@vger.kernel.org>; Mon, 18 Jan 2010 09:38:01 +0100 (CET)
Content-Disposition: inline
In-Reply-To: <201001180136.45823.rjw@sisk.pl>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

reverting this commit fixes WoL for me:

commit 166a0fd4c788ec7f10ca8194ec6d526afa12db75
Author: stephen hemminger <shemminger@vyatta.com>
Date:   Mon Dec 14 08:50:12 2009 +0000

    sky2: leave PCI config space writeable
    
    Since power management is done by PCI subsystem as well as driver,
    don't toggle the bit that disables PCI register writes.
    
    Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
    Acked-by: Rafael J. Wysocki <rjw@sisk.pl>
    Signed-off-by: David S. Miller <davem@davemloft.net>


Regards,
Tino
