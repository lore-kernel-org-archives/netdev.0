From: David Miller <davem@davemloft.net>
Subject: Re: tun: Use netif_receive_skb instead of netif_rx
Date: Wed, 19 May 2010 19:55:33 -0700 (PDT)
Message-ID: <20100519.195533.22536631.davem@davemloft.net>
References: <20100519180053.GC26519@hmsreliant.think-freely.org>
	<1274302191.3148.2.camel@lsx.localdomain>
	<4BF4517F.1010206@athenacr.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: tgraf@redhat.com, nhorman@tuxdriver.com, nhorman@redhat.com,
	eric.dumazet@gmail.com, herbert@gondor.hengli.com.au,
	netdev@vger.kernel.org
To: bmb@athenacr.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:57238
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752381Ab0ETCzY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 May 2010 22:55:24 -0400
In-Reply-To: <4BF4517F.1010206@athenacr.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Since it seems now inevitable to me that we'll need to store the
'classid' in struct sk_buff, I've prepared two patches to do that at
zero cost.

Someone please go with this.
