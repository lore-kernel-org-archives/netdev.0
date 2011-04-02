From: David Miller <davem@davemloft.net>
Subject: Re: ipv6: Add support for RTA_PREFSRC
Date: Fri, 01 Apr 2011 20:46:13 -0700 (PDT)
Message-ID: <20110401.204613.246536923.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dwalter@barracuda.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50265
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751760Ab1DBDqv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Apr 2011 23:46:51 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


You can't change the layout of "struct in6_rtmsg", as that structure
is explicitly exported to user space and changing it will break every
application out there.
