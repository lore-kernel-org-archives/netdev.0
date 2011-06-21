From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [RFC PATCH] packet: Add fanout support.
Date: Tue, 21 Jun 2011 21:05:24 +0800
Message-ID: <BANLkTikgTqGY=S9UVik6wjSp5WE4WLmKtA@mail.gmail.com>
References: <20110621.025334.547463578193934724.davem@davemloft.net>
 <4E0074CF.8070003@inliniac.net> <20110621.034627.30677905865798284.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: victor@inliniac.net, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f46.google.com ([209.85.214.46]:38327 "EHLO
	mail-bw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932080Ab1FUNFp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Jun 2011 09:05:45 -0400
Received: by bwz15 with SMTP id 15so3020971bwz.19
        for <netdev@vger.kernel.org>; Tue, 21 Jun 2011 06:05:44 -0700 (PDT)
In-Reply-To: <20110621.034627.30677905865798284.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 21, 2011 at 6:46 PM, David Miller <davem@davemloft.net> wrote:
> From: Victor Julien <victor@inliniac.net>
> Date: Tue, 21 Jun 2011 12:39:11 +0200
>
>> The hash based on skb->rxhash, does that result in a "flow" based
>> distribution over the listeners? So all packets sharing a tuple
>> being sent to the same socket?
>
> Yes, that's exactly right.

But not for fragments, in additional.


-- 
Regards,
Changli Gao(xiaosuo@gmail.com)
