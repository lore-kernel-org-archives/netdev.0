From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] af_key: mark policy as dead before destroying
Date: Thu, 06 Nov 2008 23:09:07 -0800 (PST)
Message-ID: <20081106.230907.42708270.davem@davemloft.net>
References: <20081107024954.GA20157@x200.localdomain>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: adobriyan@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:56518
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751052AbYKGHJI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 7 Nov 2008 02:09:08 -0500
In-Reply-To: <20081107024954.GA20157@x200.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexey Dobriyan <adobriyan@gmail.com>
Date: Fri, 7 Nov 2008 05:49:54 +0300

> xfrm_policy_destroy() will oops if not dead policy is passed to it.
> On error path in pfkey_compile_policy() exactly this happens.
> 
> Oopsable for CAP_NET_ADMIN owners.
> 
> Signed-off-by: Alexey Dobriyan <adobriyan@gmail.com>

Good catch, applied to net-2.6

Thanks.
