From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] netsched: Allow meta match on vlan tag on receive
Date: Mon, 13 Apr 2009 18:13:06 -0700 (PDT)
Message-ID: <20090413.181306.39229675.davem@davemloft.net>
References: <20090413173008.3278a54c@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kaber@trash.net, tgraf@suug.ch, netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38909
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1750721AbZDNBNP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 Apr 2009 21:13:15 -0400
In-Reply-To: <20090413173008.3278a54c@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Mon, 13 Apr 2009 17:30:08 -0700

> When vlan acceleration is used on receive, the vlan tag is maintained
> outside of the skb data. The existing vlan tag match only works on TX
> path because it uses vlan_get_tag which tests for VLAN_HW_TX_ACCEL.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

Looks good, applied, thanks!
