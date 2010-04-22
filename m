From: jamal <hadi@cyberus.ca>
Subject: Re: [PATCH v3] net: batch skb dequeueing from softnet
 input_pkt_queue
Date: Thu, 22 Apr 2010 08:13:48 -0400
Message-ID: <1271938428.4032.31.camel@bigi>
References: <1271238738-8386-1-git-send-email-xiaosuo@gmail.com>
	 <1271891149.7895.3751.camel@edumazet-laptop>
Reply-To: hadi@cyberus.ca
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Changli Gao <xiaosuo@gmail.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Tom Herbert <therbert@google.com>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f179.google.com ([209.85.221.179]:44811 "EHLO
	mail-qy0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753528Ab0DVMNv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Apr 2010 08:13:51 -0400
Received: by qyk9 with SMTP id 9so11106047qyk.1
        for <netdev@vger.kernel.org>; Thu, 22 Apr 2010 05:13:51 -0700 (PDT)
In-Reply-To: <1271891149.7895.3751.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2010-04-22 at 01:05 +0200, Eric Dumazet wrote:


> [RFC] net: introduce a batch mode in process_backlog()
> 
> We see a lock contention on input_pkt_queue.lock in RPS benches.
> 
> As suggested by Changli Gao, we can batch several skbs at once in
> process_backlog(), so that we dirty input_pkt_queue less often.
> 

Ok, so i grab the latest and greatest net-next and apply this before
testing? Let me know..

cheers,
jamal

