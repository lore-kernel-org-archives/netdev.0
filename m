From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH 3/5] ifb: fix tx_queue_len overlimit
Date: Wed, 15 Dec 2010 20:36:32 +0800
Message-ID: <AANLkTi=GTo=JZ5kDEXpZDNdK1RdtirP6G8TmaJARmeL+@mail.gmail.com>
References: <1292251414-5154-1-git-send-email-xiaosuo@gmail.com>
 <1292251414-5154-3-git-send-email-xiaosuo@gmail.com> <1292416439.2067.6.camel@mojatatu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f43.google.com ([209.85.161.43]:43375 "EHLO
	mail-fx0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753629Ab0LOMgx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Dec 2010 07:36:53 -0500
Received: by fxm18 with SMTP id 18so1964883fxm.2
        for <netdev@vger.kernel.org>; Wed, 15 Dec 2010 04:36:52 -0800 (PST)
In-Reply-To: <1292416439.2067.6.camel@mojatatu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 15, 2010 at 8:33 PM, jamal <hadi@cyberus.ca> wrote:
> On Mon, 2010-12-13 at 22:43 +0800, Changli Gao wrote:
>> We should check the length of rq after enqueuing, otherwise the length
>> of rq will be over tx_queue_len.
>>
>> Signed-off-by: Changli Gao <xiaosuo@gmail.com>
>
> Not sure about this one. The check is also for ==, so we are going
> to stop before we go over tx_queue_len. What am i missing?
>

But then, we put this skb into rq in any way, and the length of rq
becomes tx_queue_len + 1.



-- 
Regards,
Changli Gao(xiaosuo@gmail.com)
