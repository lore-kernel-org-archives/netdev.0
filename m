From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net] vxlan: release rt when found circular route
Date: Thu, 05 Dec 2013 04:22:28 -0800
Message-ID: <1386246148.30495.170.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1386230631-2504-1-git-send-email-fan.du@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: Fan Du <fan.du@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:59973 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751020Ab3LEMW3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Dec 2013 07:22:29 -0500
Received: by mail-pb0-f46.google.com with SMTP id md12so25541907pbc.5
        for <netdev@vger.kernel.org>; Thu, 05 Dec 2013 04:22:29 -0800 (PST)
In-Reply-To: <1386230631-2504-1-git-send-email-fan.du@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-12-05 at 16:03 +0800, Fan Du wrote:
> Otherwise causing dst memory leakage.
> Have Checked all other type tunnel device transmit implementation,
> no such things happens anymore.
> 
> Signed-off-by: Fan Du <fan.du@windriver.com>

Acked-by: Eric Dumazet <edumazet@google.com>
