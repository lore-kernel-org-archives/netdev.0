From: Jeff Haran <jharan@Brocade.COM>
Subject: NETLINK sockets dont honor SO_RCVLOWAT?
Date: Tue, 17 Nov 2009 17:54:59 -0800
Message-ID: <D67825C5985D0647BE40A5F5B0B70D1106E9C56894@HQ-EXCH-7.corp.brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hq-exedge.brocade.com ([66.243.153.82]:59483 "EHLO
	hq-exedge.brocade.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753908AbZKRB77 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Nov 2009 20:59:59 -0500
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Am I correct in my observation that the SO_RCVLOWAT socket option is not honored when one calls readv() on a PF_NETLINK socket?

The test application I wrote returns data as soon as it's available regardless of the option value I've specified and my perusal of the kernel sources leads me to believe that the NETLINK code does not honor it (support for the option appears to be protocol specific and I don't see it in the netlink code), but I could be missing something.

Please respond directly to my email address, jharan (at) brocade.com, as I do not subscribe to this list.

Thanks,

Jeff Haran
Brocade Communications
