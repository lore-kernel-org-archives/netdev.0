From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH 5/5 v4] net: add old_queue_mapping into skb->cb
Date: Tue, 21 Dec 2010 08:07:17 -0500
Message-ID: <1292936837.6535.8.camel@mojatatu>
References: <1292475410-24665-1-git-send-email-xiaosuo@gmail.com>
	 <1292591363.2668.19.camel@mojatatu>
	 <AANLkTi=Eq1HuPwMMGQjk9x0QXp3_5djmAY6JeZyFkk0k@mail.gmail.com>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Stephen Hemminger <shemminger@linux-foundation.org>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Tom Herbert <therbert@google.com>,
	Jiri Pirko <jpirko@redhat.com>, netdev@vger.kernel.org,
	netem@lists.linux-foundation.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:49875 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750987Ab0LUNH0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Dec 2010 08:07:26 -0500
Received: by yxt3 with SMTP id 3so1749616yxt.19
        for <netdev@vger.kernel.org>; Tue, 21 Dec 2010 05:07:25 -0800 (PST)
In-Reply-To: <AANLkTi=Eq1HuPwMMGQjk9x0QXp3_5djmAY6JeZyFkk0k@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2010-12-17 at 21:41 +0800, Changli Gao wrote:

Sorry for the latency - I am a little swamped.

> I doubt it can work.

It should work - this used to be part of my regression tests.
If it doesnt work something is broken.

In any case, I shouldnt have used this example because
it distracted from the point i was trying to make:
You are restoring the old qmap when the point is we could change
it to a new one. A simpler example illustrating how
a qmap could be changed:

----
tc filter add dev ifb0 parent 1:0 protocol ip prio 10 u32 \
 match u32 0 0 flowid 1:2 \
 action skbedit queue_mapping 4
---

cheers,
jamal

