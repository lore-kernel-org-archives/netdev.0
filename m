From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH] net: drop write-only stack variable
Date: Tue, 2 Feb 2016 21:50:21 +0100
Message-ID: <56B1168D.6070201@stressinduktion.org>
References: <1454433474-8888-1-git-send-email-dh.herrmann@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S . Miller" <davem@davemloft.net>
To: David Herrmann <dh.herrmann@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out1-smtp.messagingengine.com ([66.111.4.25]:55300 "EHLO
	out1-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932934AbcBBUu1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Feb 2016 15:50:27 -0500
Received: from compute6.internal (compute6.nyi.internal [10.202.2.46])
	by mailout.nyi.internal (Postfix) with ESMTP id 050B421204
	for <netdev@vger.kernel.org>; Tue,  2 Feb 2016 15:50:24 -0500 (EST)
In-Reply-To: <1454433474-8888-1-git-send-email-dh.herrmann@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02.02.2016 18:17, David Herrmann wrote:
> Remove a write-only stack variable from unix_attach_fds(). This is a
> left-over from the security fix in:
>
>      commit 712f4aad406bb1ed67f3f98d04c044191f0ff593
>      Author: willy tarreau <w@1wt.eu>
>      Date:   Sun Jan 10 07:54:56 2016 +0100
>
>          unix: properly account for FDs passed over unix sockets
>
> Signed-off-by: David Herrmann <dh.herrmann@gmail.com>

I don't think this specifically needs a Fixes tag. Seems more like a 
clean-up.

Anyway, I also noticed this during review and it can be removed safely.

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Thanks,
Hannes
