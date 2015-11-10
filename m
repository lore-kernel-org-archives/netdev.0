From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net v2] af-unix: fix use-after-free with concurrent readers
 while splicing
Date: Tue, 10 Nov 2015 16:24:31 +0100
Message-ID: <1447169071.771708.435046929.6206CA34@webmail.messagingengine.com>
References: <1447166859-11766-1-git-send-email-hannes@stressinduktion.org>
 <1447168724.17135.73.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Dmitry Vyukov <dvyukov@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4-smtp.messagingengine.com ([66.111.4.28]:48720 "EHLO
	out4-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752791AbbKJPYc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 Nov 2015 10:24:32 -0500
Received: from compute1.internal (compute1.nyi.internal [10.202.2.41])
	by mailout.nyi.internal (Postfix) with ESMTP id B8A2920E8C
	for <netdev@vger.kernel.org>; Tue, 10 Nov 2015 10:24:31 -0500 (EST)
In-Reply-To: <1447168724.17135.73.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 10, 2015, at 16:18, Eric Dumazet wrote:
> Please Hannes include the Fixes: tag.

Yep, sorry, is done in v3.

> As you might already know, patchwork does not catch it later
> 
> Fixes: 2b514574f7e8 ("net: af_unix: implement splice for stream af_unix
> sockets")
> Acked-by: Eric Dumazet <edumazet@google.com>
> 
> Also I would prefer skb_get() being on a separate line, to ease future
> understanding of the code.

Okay, indeed it is more visible. I changed the code, thanks!

Bye,
Hannes
