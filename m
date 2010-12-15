From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 3/5] ifb: fix tx_queue_len overlimit
Date: Wed, 15 Dec 2010 07:33:59 -0500
Message-ID: <1292416439.2067.6.camel@mojatatu>
References: <1292251414-5154-1-git-send-email-xiaosuo@gmail.com>
	 <1292251414-5154-3-git-send-email-xiaosuo@gmail.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:37890 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753272Ab0LOMjd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Dec 2010 07:39:33 -0500
Received: by iyi12 with SMTP id 12so870836iyi.19
        for <netdev@vger.kernel.org>; Wed, 15 Dec 2010 04:39:32 -0800 (PST)
In-Reply-To: <1292251414-5154-3-git-send-email-xiaosuo@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2010-12-13 at 22:43 +0800, Changli Gao wrote:
> We should check the length of rq after enqueuing, otherwise the length
> of rq will be over tx_queue_len.
> 
> Signed-off-by: Changli Gao <xiaosuo@gmail.com>

Not sure about this one. The check is also for ==, so we are going
to stop before we go over tx_queue_len. What am i missing?

cheers,
jamal

