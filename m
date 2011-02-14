From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-26 1/5] cxgb4vf: Virtual Interfaces are always up
 ...
Date: Mon, 14 Feb 2011 14:34:23 -0800 (PST)
Message-ID: <20110214.143423.71126258.davem@davemloft.net>
References: <20110211.211939.70197667.davem@davemloft.net>
	<201102141113.58068.leedom@chelsio.com>
	<201102141431.32535.leedom@chelsio.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: leedom@chelsio.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59398
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751192Ab1BNWdr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Feb 2011 17:33:47 -0500
In-Reply-To: <201102141431.32535.leedom@chelsio.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Casey Leedom <leedom@chelsio.com>
Date: Mon, 14 Feb 2011 14:31:32 -0800

> | From: Casey Leedom <leedom@chelsio.com>
> | Date: Monday, February 14, 2011 11:13 am
> | 
> | | No driver specific module parameters!  Add something generic and common
> | | so other drivers can use it too.
> | | 
> | | Otherwise every user has to learn a different way to control this
> | | attribute, depending upon the device type, which is rediculious.
> | | 
> | | How many times do we have to tell driver authors this?
> | 
> |   Sorry.  I wasn't aware of this rule.  My bad.  Is this writeen down
> | somewhere under Documentation?  I'm not being snarky.  I really would like
> | to know so I can read through the general ground rules and avoid making
> | more mistakes in the future.
> | 
> |   As for a generic mechanism, what's the preferred way of doing this?  A
> | new ethtool flag?  Sorry for being a doofus here, I'm happy to follow
> | whatever the accepted standard is.  Thanks for your time and patience.
> 
>   Also, I assume then the the entire patch series is now rejected, right?  And 
> that I should resubmit the patch series without the unacceptable module 
> parameter, right?  I'm just trying to figure out what I need to do next.  

You need to resubmit the whole series, because changing an earlier
patch causes the subsequent ones to have, at a minimum, offsets which
GIT apply will reject.
