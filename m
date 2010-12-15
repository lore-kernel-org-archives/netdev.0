From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH 5/5] net: add skb.old_queue_mapping
Date: Wed, 15 Dec 2010 20:52:36 +0800
Message-ID: <AANLkTi=zNTV1sBArK+VCOx-5eF17q+Y9AtgJaCDMuEj1@mail.gmail.com>
References: <1292251414-5154-1-git-send-email-xiaosuo@gmail.com>
 <1292251414-5154-5-git-send-email-xiaosuo@gmail.com> <1292416832.2067.13.camel@mojatatu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f43.google.com ([209.85.161.43]:33659 "EHLO
	mail-fx0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753679Ab0LOMw5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Dec 2010 07:52:57 -0500
Received: by fxm18 with SMTP id 18so1981072fxm.2
        for <netdev@vger.kernel.org>; Wed, 15 Dec 2010 04:52:56 -0800 (PST)
In-Reply-To: <1292416832.2067.13.camel@mojatatu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 15, 2010 at 8:40 PM, jamal <hadi@cyberus.ca> wrote:
> On Mon, 2010-12-13 at 22:43 +0800, Changli Gao wrote:
>>
>> dev_pick_tx() use the current queue_mapping for the skbs reinjected
>> by ifb.
>
> You are hard-coding policy here, no? ifb can do a lot of funky things
> which change the nature of the flow. I can shape, i can edit packets
> etc. Why is the queue mapping any different?
>

It seems reasonable. Thanks. I'll remove this hard-coding policy.

-- 
Regards,
Changli Gao(xiaosuo@gmail.com)
