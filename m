From: David Miller <davem@davemloft.net>
Subject: Re: RFC: how to control device specific features. sysfs or mod
 param?
Date: Sat, 05 Dec 2009 02:13:21 -0800 (PST)
Message-ID: <20091205.021321.73648278.davem@davemloft.net>
References: <1260006955.3565.12.camel@localhost>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: peter.p.waskiewicz.jr@intel.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:58217
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753549AbZLEKNO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Dec 2009 05:13:14 -0500
In-Reply-To: <1260006955.3565.12.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Peter P Waskiewicz Jr <peter.p.waskiewicz.jr@intel.com>
Date: Sat, 05 Dec 2009 01:55:55 -0800

> My question is I want to toggle the underlying hardware mode to use one
> or the other filter mechanism.  I can either do this using a module
> parameter, which I'd like to avoid, or I can do this in a sysfs
> parameter.  What do people think is the best approach?  Is there another
> option I'm not considering here?

Other than sysfs another option to consider is trying to fit
this into the ethtool framework somehow.
