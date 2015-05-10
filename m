From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH-net] af_packet / TX_RING not fully non-blocking (w/
 MSG_DONTWAIT).
Date: Sun, 10 May 2015 19:40:31 -0400 (EDT)
Message-ID: <20150510.194031.149375433174785061.davem@davemloft.net>
References: <1431092677-19853-1-git-send-email-mathias.kretschmer@fokus.fraunhofer.de>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: mathias.kretschmer@fokus.fraunhofer.de
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([149.20.54.216]:56785 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751755AbbEJXkc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 May 2015 19:40:32 -0400
In-Reply-To: <1431092677-19853-1-git-send-email-mathias.kretschmer@fokus.fraunhofer.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mathias Kretschmer <mathias.kretschmer@fokus.fraunhofer.de>
Date: Fri, 8 May 2015 15:44:37 +0200

> This patch fixes an issue where the send(MSG_DONTWAIT) call
> on a TX_RING is not fully non-blocking in cases where the device's sndBuf is
> full. We pass nonblock=true to sock_alloc_send_skb() and return any possibly
> occuring error code (most likely EGAIN) to the caller. As the fast-path stays
> as it is, we keep the unlikely() around skb == NULL. 
> 
> Signed-off-by: Mathias Kretschmer <mathias.kretschmer@fokus.fraunhofer.de>

This looks correct to me, applied, thank you.
