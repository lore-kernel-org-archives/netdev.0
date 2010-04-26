From: David Miller <davem@davemloft.net>
Subject: Re: [net-next-2.6 PATCH 1/2] Add ndo_set_vf_port_profile
Date: Mon, 26 Apr 2010 13:25:47 -0700 (PDT)
Message-ID: <20100426.132547.70198275.davem@davemloft.net>
References: <C7FB3747.2BAAA%scofeldm@cisco.com>
	<C7FB3E22.2BAEE%scofeldm@cisco.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, chrisw@redhat.com, arnd@arndb.de
To: scofeldm@cisco.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38148
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754919Ab0DZUZm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Apr 2010 16:25:42 -0400
In-Reply-To: <C7FB3E22.2BAEE%scofeldm@cisco.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Scott Feldman <scofeldm@cisco.com>
Date: Mon, 26 Apr 2010 12:57:06 -0700

> Hmmm....even that isn't so nice because the port-profile info for all VFs is
> going to get stuffed into the RTM_GETLINK skb, and I assume there are limits
> on the skb return size.

It's probably better to use .dump() for this, which allows to return
the result in multiple SKBs.
