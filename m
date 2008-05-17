From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 5/6] [BNX2]: Pre-initialize struct cpu_reg.
Date: Fri, 16 May 2008 22:20:35 -0700 (PDT)
Message-ID: <20080516.222035.253970824.davem@davemloft.net>
References: <1210973448.5507.21.camel@dell>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, andy@greyhouse.net, benli@broadcom.com
To: mchan@broadcom.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57753
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1751505AbYEQFUl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 17 May 2008 01:20:41 -0400
In-Reply-To: <1210973448.5507.21.camel@dell>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: "Michael Chan" <mchan@broadcom.com>
Date: Fri, 16 May 2008 14:30:48 -0700

> [BNX2]: Pre-initialize struct cpu_reg.
> 
> Instead of assigning values for the struct cpu_reg's at runtime,
> we already know these values at compile time.  Therefore, we can use
> designated initializers, to initialize these structures and not have
> to incur this assignment cost at run-time.
> 
> Signed-off-by: Benjamin Li <benli@broadcom.com>
> Signed-off-by: Michael Chan <mchan@broadcom.com>

Applied.
