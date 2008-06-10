From: David Miller <davem@davemloft.net>
Subject: Re: ping6 ff02::1 on eth0 shows echo reply on lo
Date: Tue, 10 Jun 2008 12:42:11 -0700 (PDT)
Message-ID: <20080610.124211.63104092.davem@davemloft.net>
References: <59F16AFE-888B-484E-B04A-CBFDA318ED17@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: chasedouglas@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:59936
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753246AbYFJTmL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Jun 2008 15:42:11 -0400
In-Reply-To: <59F16AFE-888B-484E-B04A-CBFDA318ED17@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Chase Douglas <chasedouglas@gmail.com>
Date: Tue, 10 Jun 2008 15:32:34 -0400

> While doing some testing, I've found that a ping request sent only on  
> eth0 to link-local addresses (ping6 -I eth0 ff02::1) is causing lo to  
> generate echo replies. Is this intended behavior or a bug somewhere?

Intended behavior.

When the kernel knows it's for the local machine, even if the address
is attached to a physical device, it routes the packet over loopback.
