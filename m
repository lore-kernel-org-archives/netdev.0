From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 2/2] ppp_generic: handle non-linear skbs when
 passing them to pppd
Date: Mon, 03 May 2010 13:27:14 -0700 (PDT)
Message-ID: <20100503.132714.09765870.davem@davemloft.net>
References: <4BDF2FD5.2030509@simon.arlott.org.uk>
	<4BDF300B.1040103@simon.arlott.org.uk>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, paulus@samba.org, linux-ppp@vger.kernel.org
To: simon@fire.lp0.eu
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:50719
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1756729Ab0ECU1H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 May 2010 16:27:07 -0400
In-Reply-To: <4BDF300B.1040103@simon.arlott.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Simon Arlott <simon@fire.lp0.eu>
Date: Mon, 03 May 2010 21:20:27 +0100

> Frequently when using PPPoE with an interface MTU greater than 1500,
> the skb is likely to be non-linear. If the skb needs to be passed to
> pppd then the skb data must be read correctly.
> 
> The previous commit fixes an issue with accidentally sending skbs
> to pppd based on an invalid read of the protocol type. When that
> error occurred pppd was reading invalid skb data too.
> 
> Signed-off-by: Simon Arlott <simon@fire.lp0.eu>

Applied.
