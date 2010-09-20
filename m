From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH] xfrm: Allow different selector family in temporary
 state
Date: Mon, 20 Sep 2010 11:11:49 -0700 (PDT)
Message-ID: <20100920.111149.45908739.davem@davemloft.net>
References: <20100920115253.GG4134@gauss.secunet.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: herbert@gondor.apana.org.au, thomas.egerer@secunet.com,
	netdev@vger.kernel.org
To: steffen.klassert@secunet.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:39287
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755836Ab0ITSLa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Sep 2010 14:11:30 -0400
In-Reply-To: <20100920115253.GG4134@gauss.secunet.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Steffen Klassert <steffen.klassert@secunet.com>
Date: Mon, 20 Sep 2010 13:52:53 +0200

> From: Thomas Egerer <thomas.egerer@secunet.com>
> 
> The family parameter xfrm_state_find is used to find a state matching a
> certain policy. This value is set to the template's family
> (encap_family) right before xfrm_state_find is called.
> The family parameter is however also used to construct a temporary state
> in xfrm_state_find itself which is wrong for inter-family scenarios
> because it produces a selector for the wrong family. Since this selector
> is included in the xfrm_user_acquire structure, user space programs
> misinterpret IPv6 addresses as IPv4 and vice versa.
> This patch splits up the original init_tempsel function into a part that
> initializes the selector respectively the props and id of the temporary
> state, to allow for differing ip address families whithin the state.
> 
> Signed-off-by: Thomas Egerer <thomas.egerer@secunet.com>
> Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>

Looks good, applied, thanks a lot.
