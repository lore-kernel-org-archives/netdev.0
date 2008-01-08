From: David Miller <davem@davemloft.net>
Subject: Re: [XFRM]: xfrm_state_clone() should be static, not exported
Date: Tue, 08 Jan 2008 01:36:13 -0800 (PST)
Message-ID: <20080108.013613.179218949.davem@davemloft.net>
References: <47832D94.3000302@cosmosbay.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: dada1@cosmosbay.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:44318
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1753483AbYAHJgN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jan 2008 04:36:13 -0500
In-Reply-To: <47832D94.3000302@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <dada1@cosmosbay.com>
Date: Tue, 08 Jan 2008 09:00:20 +0100

> xfrm_state_clone() is not used outside of net/xfrm/xfrm_state.c
> There is no need to export it.
> 
> Spoted by sparse checker.
>    CHECK   net/xfrm/xfrm_state.c
> net/xfrm/xfrm_state.c:1103:19: warning: symbol 'xfrm_state_clone' was not 
> declared. Should it be static?
> 
> Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

Applied to net-2.6.25, thanks Eric.
