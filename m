From: David Miller <davem@davemloft.net>
Subject: Re: [RFC] LSM hook for post recvmsg.
Date: Fri, 16 Jul 2010 12:35:58 -0700 (PDT)
Message-ID: <20100716.123558.71592004.davem@davemloft.net>
References: <201007170114.GFC57373.SQJHOVtLFMOFFO@I-love.SAKURA.ne.jp>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: penguin-kernel@I-love.SAKURA.ne.jp
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41284
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754865Ab0GPTfm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Jul 2010 15:35:42 -0400
In-Reply-To: <201007170114.GFC57373.SQJHOVtLFMOFFO@I-love.SAKURA.ne.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Date: Sat, 17 Jul 2010 01:14:38 +0900

> Below is a patch for post recvmsg() operation. I modified the patch to call
> skb_recv_datagram() again (for udp_recvmsg(), raw_recvmsg(), udpv6_recvmsg())
> if LSM dicided to drop the message. (Regarding rawv6_recvmsg(), I didn't do so
> in accordance with the comment at "csum_copy_err:".)
> What do you think about this verion?

This looks fine, but regardless of that comment I think the IPV6 raw recvmsg()
should loop just as the IPV4 one does in your patch.
