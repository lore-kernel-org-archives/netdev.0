From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH v6] net: batch skb dequeueing from softnet
 input_pkt_queue
Date: Mon, 26 Apr 2010 17:03:11 -0400
Message-ID: <1272315791.8918.41.camel@bigi>
References: <1272010378-2955-1-git-send-email-xiaosuo@gmail.com>
	 <1272014825.7895.7851.camel@edumazet-laptop> <1272060153.8918.8.camel@bigi>
	 <1272118252.8918.13.camel@bigi> <1272290584.19143.43.camel@edumazet-laptop>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Changli Gao <xiaosuo@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Tom Herbert <therbert@google.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-px0-f174.google.com ([209.85.212.174]:43550 "EHLO
	mail-px0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751918Ab0DZVDQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Apr 2010 17:03:16 -0400
Received: by pxi17 with SMTP id 17so1860909pxi.19
        for <netdev@vger.kernel.org>; Mon, 26 Apr 2010 14:03:15 -0700 (PDT)
In-Reply-To: <1272290584.19143.43.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2010-04-26 at 16:03 +0200, Eric Dumazet wrote:

> 
> Jamal, I have a Nehalem setup now, and I can see
> _raw_spin_lock_irqsave() abuse is not coming from network tree, but from
> clockevents_notify()

yikes. Thanks Eric - I shouldve been able to figure that one out. But
why is this thing expensive? I will run the test tommorow and see if i
see the same thing. 

cheers,
jamal



