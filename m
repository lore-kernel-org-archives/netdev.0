From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 0/6] net: Call skb_get_hash in qdiscs
Date: Wed, 04 Mar 2015 14:31:13 -0800
Message-ID: <1425508273.5130.236.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1425494404-24114-1-git-send-email-therbert@google.com>
	 <1425499383.5130.227.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CA+mtBx8Y+AQ5nc5B=qvBZnJOpgTVy0Q6VFMR3r9t6MPrGb5gRA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Florian Westphal <fw@strlen.de>
To: Tom Herbert <therbert@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f175.google.com ([209.85.223.175]:38256 "EHLO
	mail-ie0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751824AbbCDWbP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Mar 2015 17:31:15 -0500
Received: by iecrd18 with SMTP id rd18so71460029iec.5
        for <netdev@vger.kernel.org>; Wed, 04 Mar 2015 14:31:14 -0800 (PST)
In-Reply-To: <CA+mtBx8Y+AQ5nc5B=qvBZnJOpgTVy0Q6VFMR3r9t6MPrGb5gRA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2015-03-04 at 13:49 -0800, Tom Herbert wrote:

> Then choke is broke :-) ipv6_addr_hash already makes the "flow" match
> stochastic.

Right, so lets break IPv4 as well ;)

What about fixing bugs, instead of adding new ones ?
