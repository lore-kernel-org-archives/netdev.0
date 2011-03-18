From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] ethtool: __ethtool_set_sg: check for function pointer
 before using it
Date: Fri, 18 Mar 2011 15:15:59 -0700 (PDT)
Message-ID: <20110318.151559.13735292.davem@davemloft.net>
References: <20110317163720.GA26284@core.hellgate.ch>
	<1300380733.2569.3.camel@bwh-desktop>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: rl@hellgate.ch, mirq-linux@rere.qmqm.pl, netdev@vger.kernel.org
To: bhutchings@solarflare.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:43757
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932338Ab1CRWPV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Mar 2011 18:15:21 -0400
In-Reply-To: <1300380733.2569.3.camel@bwh-desktop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ben Hutchings <bhutchings@solarflare.com>
Date: Thu, 17 Mar 2011 16:52:13 +0000

> On Thu, 2011-03-17 at 17:37 +0100, Roger Luethi wrote:
>> __ethtool_set_sg does not check if dev->ethtool_ops->set_sg is defined
>> which can result in a NULL pointer dereference when ethtool is used to
>> change SG settings for drivers without SG support.
>> 
>> Signed-off-by: Roger Luethi <rl@hellgate.ch>
> Reviewed-by: Ben Hutchings <bhutchings@solarflare.com>

Applied.
