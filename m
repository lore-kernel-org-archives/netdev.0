From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: How to best consolidate list of skbs (msdu) for receive?
Date: Thu, 27 Feb 2014 15:03:15 -0800
Message-ID: <1393542195.26794.50.camel@edumazet-glaptop2.roam.corp.google.com>
References: <530F85AE.8060002@candelatech.com>
	   <CAGVrzcajmuGQRi84WqWrxyUK2+xG1+b7EMTwRk4WpsDnp0B7qQ@mail.gmail.com>
	  <1393536113.26794.41.camel@edumazet-glaptop2.roam.corp.google.com>
	  <530FB348.2070701@candelatech.com>
	 <1393540305.26794.47.camel@edumazet-glaptop2.roam.corp.google.com>
	 <530FBE51.8040905@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Florian Fainelli <f.fainelli@gmail.com>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f176.google.com ([209.85.223.176]:38851 "EHLO
	mail-ie0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751213AbaB0XDW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Feb 2014 18:03:22 -0500
In-Reply-To: <530FBE51.8040905@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2014-02-27 at 14:38 -0800, Ben Greear wrote:

> Based on the code above, do you think skb_try_coalesce() is
> the best option for this logic?

Yep, if you do not know how are built the skb in the chain, I would say
using skb_try_coalesce() seems the proper way.

We use it for example in tcp input path.

Take also a look at tipc_link_recv_fragment()
