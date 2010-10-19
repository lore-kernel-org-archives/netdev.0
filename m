From: Yevgeny Petrilin <yevgenyp@mellanox.co.il>
Subject: RE: [PATCH net-next-2.6] mlx4:  make functions local and remove
	dead	code.
Date: Tue, 19 Oct 2010 09:37:44 +0200
Message-ID: <E113D394D7C5DB4F8FF691FA7EE9DB443CC3716F65@MTLMAIL.mtl.com>
References: <20101018083059.164fc8d8@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Eli Cohen <eli@mellanox.co.il>
To: Stephen Hemminger <shemminger@vyatta.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.mellanox.co.il ([194.90.237.43]:59834 "EHLO mellanox.co.il"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S933130Ab0JSHht convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Oct 2010 03:37:49 -0400
In-Reply-To: <20101018083059.164fc8d8@nehalam>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> 
> There is a whole section of code in this driver related to vlan tables
> which is not accessed from any kernel code.
> 
> Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>
>

Thanks for sending this, 
There are patches under review at the moment (RDMA over Ethernet) that use this code:
http://www.spinics.net/lists/linux-rdma/msg05512.html, which will be broken if the VLAN tables code is removed.


Thanks,
Yevgeny
 
