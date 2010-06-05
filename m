From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH] act_mirred: don't clone skb when skb isn't shared
Date: Sat, 05 Jun 2010 09:24:59 -0400
Message-ID: <1275744299.3490.48.camel@bigi>
References: <1275658990-15838-1-git-send-email-xiaosuo@gmail.com>
	 <1275742435.3490.31.camel@bigi>
	 <AANLkTikHqzIr-SjPZe-iiMPxVG9PRR9-0A9qeMwzfLYp@mail.gmail.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:37915 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751574Ab0FENZC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Jun 2010 09:25:02 -0400
Received: by vws5 with SMTP id 5so1011353vws.19
        for <netdev@vger.kernel.org>; Sat, 05 Jun 2010 06:25:01 -0700 (PDT)
In-Reply-To: <AANLkTikHqzIr-SjPZe-iiMPxVG9PRR9-0A9qeMwzfLYp@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2010-06-05 at 21:07 +0800, Changli Gao wrote:

> Thanks. BTW: act_nat.c doesn't obey the following rule, and you plan
> to remove TC_MUNGED and TC_OK2MUNGE?

> 2) If you munge any packet thou shalt call pskb_expand_head in the case
> someone else is referencing the skb. After that you "own" the skb.
> You must also tell us if it is ok to munge the packet (TC_OK2MUNGE),
> this way any action downstream can stomp on the packet.

That rule still applies but it is upto the discretion of the action.
i.e if the act_nat thinks it is ok for others down the street to trample
on the packet, it should tell us so. Maybe i should change the wording
to use the word "may" in that 3rd sentence.
[I will kill (low prio) TC_OK2MUNGE but not TC_MUNGED.]

cheers,
jamal

