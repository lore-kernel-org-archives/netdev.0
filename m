From: Casey Leedom <leedom@chelsio.com>
Subject: Re: [PATCH net-26 1/5] cxgb4vf: Virtual Interfaces are always up ...
Date: Mon, 14 Feb 2011 11:13:57 -0800
Message-ID: <201102141113.58068.leedom@chelsio.com>
References: <1297472423-15672-1-git-send-email-leedom@chelsio.com> <1297472423-15672-2-git-send-email-leedom@chelsio.com> <20110211.211939.70197667.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stargate.chelsio.com ([67.207.112.58]:26363 "EHLO
	stargate.chelsio.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750800Ab1BNTN7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Feb 2011 14:13:59 -0500
In-Reply-To: <20110211.211939.70197667.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

| From: David Miller <davem@davemloft.net>
| Date: Friday, February 11, 2011 09:19 pm
| 
| From: Casey Leedom <leedom@chelsio.com>
| Date: Fri, 11 Feb 2011 17:00:19 -0800
| 
| > Implement new default mode of always reporting the Virtual Interface link
| > as being "up".  This allows different Virtual Interfaces on the same
| > port to continue to communicate with each other even when the physical
| > port link is down.  This new behavior is controlled via the module
| > parameter
| > force_link_up (default 1).  The old behavior can be achieved by setting
| > force_link_up=0.
| > 
| > Signed-off-by: Casey Leedom <leedom@chelsio.com>
| 
| No driver specific module parameters!  Add something generic and common
| so other drivers can use it too.
| 
| Otherwise every user has to learn a different way to control this
| attribute, depending upon the device type, which is rediculious.
| 
| How many times do we have to tell driver authors this?

  Sorry.  I wasn't aware of this rule.  My bad.  Is this writeen down somewhere 
under Documentation?  I'm not being snarky.  I really would like to know so I 
can read through the general ground rules and avoid making more mistakes in the 
future.

  As for a generic mechanism, what's the preferred way of doing this?  A new 
ethtool flag?  Sorry for being a doofus here, I'm happy to follow whatever the 
accepted standard is.  Thanks for your time and patience.

Casey
