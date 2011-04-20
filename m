From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] bonding: 802.3ad - fix agg_device_up
Date: Wed, 20 Apr 2011 01:45:36 -0700 (PDT)
Message-ID: <20110420.014536.70181162.davem@davemloft.net>
References: <20110419120955.GA14302@midget.suse.cz>
	<21326.1303232103@death>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: jbohac@suse.cz, netdev@vger.kernel.org, andy@greyhouse.net,
	shemminger@vyatta.com
To: fubar@us.ibm.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54265
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752257Ab1DTIqK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Apr 2011 04:46:10 -0400
In-Reply-To: <21326.1303232103@death>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jay Vosburgh <fubar@us.ibm.com>
Date: Tue, 19 Apr 2011 09:55:03 -0700

> Jiri Bohac <jbohac@suse.cz> wrote:
> 
>>The slave member of struct aggregator does not necessarily point
>>to a slave which is part of the aggregator. It points to the
>>slave structure containing the aggregator structure, while
>>completely different slaves (or no slaves at all) may be part of
>>the aggregator.
>>
>>The agg_device_up() function wrongly uses agg->slave to find the state of the
>>aggregator.  Use agg->lag_ports->slave instead. The bug has been
>>introduced by commit 4cd6fe1c6483cde93e2ec91f58b7af9c9eea51ad.
>>
>>Signed-off-by: Jiri Bohac <jbohac@suse.cz>
> 
> 	One additional note: port->slave can be NULL when the slave is
> transitioning in or out of the bond, but not when the port is part of an
> aggregator, so this usage should be safe.
> 
> 	-J
> 
> Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>

Applied and queued up for -stable, thanks.
