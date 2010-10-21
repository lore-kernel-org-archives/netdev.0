From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next-2.6] mlx4: make functions local and remove
 dead code.
Date: Thu, 21 Oct 2010 03:13:56 -0700 (PDT)
Message-ID: <20101021.031356.115939257.davem@davemloft.net>
References: <20101018083059.164fc8d8@nehalam>
	<E113D394D7C5DB4F8FF691FA7EE9DB443CC3716F65@MTLMAIL.mtl.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: shemminger@vyatta.com, netdev@vger.kernel.org, eli@mellanox.co.il
To: yevgenyp@mellanox.co.il
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:60518
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754261Ab0JUKNd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Oct 2010 06:13:33 -0400
In-Reply-To: <E113D394D7C5DB4F8FF691FA7EE9DB443CC3716F65@MTLMAIL.mtl.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Date: Tue, 19 Oct 2010 09:37:44 +0200

>> 
>> There is a whole section of code in this driver related to vlan tables
>> which is not accessed from any kernel code.
>> 
>> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
>>
> 
> Thanks for sending this, 
> There are patches under review at the moment (RDMA over Ethernet) that use this code:
> http://www.spinics.net/lists/linux-rdma/msg05512.html, which will be broken if the VLAN tables code is removed.

ok.
