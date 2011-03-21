From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2] xfrm: Fix initialize repl field of struct xfrm_state
Date: Mon, 21 Mar 2011 01:01:38 -0700 (PDT)
Message-ID: <20110321.010138.115940045.davem@davemloft.net>
References: <20110320.234606.183056322.davem@davemloft.net>
	<4D8701C3.5010304@cn.fujitsu.com>
	<20110321.010037.59680394.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, steffen.klassert@secunet.com
To: yjwei@cn.fujitsu.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:54678
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751120Ab1CUIA7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Mar 2011 04:00:59 -0400
In-Reply-To: <20110321.010037.59680394.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Miller <davem@davemloft.net>
Date: Mon, 21 Mar 2011 01:00:37 -0700 (PDT)

> From: Wei Yongjun <yjwei@cn.fujitsu.com>
> Date: Mon, 21 Mar 2011 15:44:03 +0800
> 
>> -int xfrm_init_state(struct xfrm_state *x)
>> +int __xfrm_init_state(struct xfrm_state *x, bool init_replay)
> 
> Since it is referenced by modules, this new function symbol must
> be exported to them.

BTW, this is one of the reasons I explicitly mentioned to make
this an inline function. :-)

