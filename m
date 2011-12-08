From: WANG Cong <xiyou.wangcong@gmail.com>
Subject: Re: [PATCH] add netpoll support for 802.1q vlans
Date: Thu, 8 Dec 2011 09:14:55 +0000 (UTC)
Message-ID: <jbpv6f$r2p$1@dough.gmane.org>
References: <20111207010424.GA16496@kvack.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from lo.gmane.org ([80.91.229.12]:43134 "EHLO lo.gmane.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750863Ab1LHJPM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Dec 2011 04:15:12 -0500
Received: from list by lo.gmane.org with local (Exim 4.69)
	(envelope-from <linux-netdev-2@m.gmane.org>)
	id 1RYa4N-0006qd-1k
	for netdev@vger.kernel.org; Thu, 08 Dec 2011 10:15:11 +0100
Received: from 180.129.255.189 ([180.129.255.189])
        by main.gmane.org with esmtp (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Thu, 08 Dec 2011 10:15:10 +0100
Received: from xiyou.wangcong by 180.129.255.189 with local (Gmexim 0.1 (Debian))
        id 1AlnuQ-0007hv-00
        for <netdev@vger.kernel.org>; Thu, 08 Dec 2011 10:15:10 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 06 Dec 2011 20:04:24 -0500, Benjamin LaHaise wrote:

> Add netpoll support to 802.1q vlan devices.  Based on the netpoll
> support in the bridging code.  Tested on a forced_eth device with
> netconsole.
> 
> Signed-off-by: Benjamin LaHaise <bcrl@kvack.org>

You also need to handle DEL_VLAN_CMD case.
