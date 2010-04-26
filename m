From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH v6] net: batch skb dequeueing from softnet
 input_pkt_queue
Date: Mon, 26 Apr 2010 17:06:47 -0400
Message-ID: <1272316007.8918.45.camel@bigi>
References: <1272010378-2955-1-git-send-email-xiaosuo@gmail.com>
	 <1272014825.7895.7851.camel@edumazet-laptop> <1272060153.8918.8.camel@bigi>
	 <1272118252.8918.13.camel@bigi> <1272290584.19143.43.camel@edumazet-laptop>
	 <1272293707.19143.51.camel@edumazet-laptop>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Changli Gao <xiaosuo@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Tom Herbert <therbert@google.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	netdev@vger.kernel.org, Andi Kleen <andi@firstfloor.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f179.google.com ([209.85.221.179]:64899 "EHLO
	mail-qy0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752516Ab0DZVGv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Apr 2010 17:06:51 -0400
Received: by qyk9 with SMTP id 9so18030937qyk.1
        for <netdev@vger.kernel.org>; Mon, 26 Apr 2010 14:06:50 -0700 (PDT)
In-Reply-To: <1272293707.19143.51.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2010-04-26 at 16:55 +0200, Eric Dumazet wrote:

> Another interesting finding:
> 
> - if all packets are received on a single queue, max speed seems to be
> 1.200.000 packets per second on my machine :-(

Well, if any consolation, it is not as bad as sky2 hardware;-> I cant do
more than 750Kpps.
Also, it seems you use VLANS - max pps will be lower than without VLANs
by probably maybe 6-70Kpps (doesnt explain the 1.2Mpps of course).

cheers,
jamal

