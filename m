From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 2.4.35.3] Fix the "InAddrErrors" increasing problem
Date: Mon, 22 Oct 2007 00:23:00 -0700 (PDT)
Message-ID: <20071022.002300.74732550.davem@davemloft.net>
References: <OF2D84A661.11AB43B8-ON6525737C.002349E6-6525737C.00238C77@in.ibm.com>
	<471C4CF6.1000206@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: krkumar2@in.ibm.com, netdev@vger.kernel.org
To: guijianfeng@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:46864
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751205AbXJVHWq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 22 Oct 2007 03:22:46 -0400
In-Reply-To: <471C4CF6.1000206@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Gui Jianfeng <guijianfeng@cn.fujitsu.com>
Date: Mon, 22 Oct 2007 15:10:46 +0800

> sorry for my careless, here is the correct one
> 
> Signed-off-by: Gui Jianfeng <guijianfeng@cn.fujitsu.com>

BTW, I would also like to say that I think a statistics correction is
totally inappropriate for the 2.4.x kernel series which is in super
maintainence mode.

Only crash fixes and fixes for bugs that severely harm functionality
should go into that tree.

These obscure statistic counter cases absolutely do not qualify.
