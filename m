From: David Miller <davem@davemloft.net>
Subject: Re: [BUG] VPN broken in net-next
Date: Wed, 02 Mar 2011 16:43:33 -0800 (PST)
Message-ID: <20110302.164333.116393112.davem@davemloft.net>
References: <20110302162826.59f52c77@nehalam>
	<20110302164114.2e110ea0@nehalam>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35979
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753827Ab1CCAm4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Mar 2011 19:42:56 -0500
In-Reply-To: <20110302164114.2e110ea0@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Stephen Hemminger <shemminger@vyatta.com>
Date: Wed, 2 Mar 2011 16:41:14 -0800

> __ip_dev_find is being called with 10.250.0.105 and failing.

What is in the interface address lists at the time of the call?
Ie. "ip a l"?
