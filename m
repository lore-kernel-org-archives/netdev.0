From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] net: implement dev_disable_lro() hw_features
 compatibility
Date: Fri, 18 Mar 2011 12:43:32 -0700 (PDT)
Message-ID: <20110318.124332.242116560.davem@davemloft.net>
References: <37d3c96bc52c87fcd4cdd39c9c852b1d2bbc249d.1300466356.git.mirq-linux@rere.qmqm.pl>
	<1300471986.2589.26.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: mirq-linux@rere.qmqm.pl, netdev@vger.kernel.org
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:51335
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932300Ab1CRTmy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Mar 2011 15:42:54 -0400
In-Reply-To: <1300471986.2589.26.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Fri, 18 Mar 2011 18:13:06 +0000

> Local function declarations are a very bad idea, as they are not checked
> against the function definition.  Please declare the function in
> <linux/ethtool.h>; that does not oblige us to export it.

Agreed.
