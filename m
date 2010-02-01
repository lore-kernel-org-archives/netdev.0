From: David Miller <davem@davemloft.net>
Subject: Re: [Patch v2] net: export TCP send buffer size via netlink
Date: Mon, 01 Feb 2010 02:06:22 -0800 (PST)
Message-ID: <20100201.020622.91421099.davem@davemloft.net>
References: <20100201092153.4194.91507.sendpatchset@localhost.localdomain>
	<20100201.020055.57470143.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	eric.dumazet@gmail.com
To: amwang@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:38689
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750910Ab0BAKGJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 1 Feb 2010 05:06:09 -0500
In-Reply-To: <20100201.020055.57470143.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Before you spend the next couple hours trying to figure out what to
do...

We already provide the information you're trying to export via
linux/inet_diag.h:inet_diag_meminfo

I hope the light goes on now :-)



