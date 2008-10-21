From: Robert Olsson <robert@robur.slu.se>
Subject: Re: [PATCH] sky2: skb recycling
Date: Tue, 21 Oct 2008 14:17:43 +0200
Message-ID: <18685.51303.285228.177350@robur.slu.se>
References: <20081020190922.7dd6510a@extreme>
	<48FD6E8A.6060304@cosmosbay.com>
	<18685.37380.34636.316536@robur.slu.se>
	<48FD97AB.1040007@baidu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Robert Olsson <Robert.Olsson@data.slu.se>,
	Eric Dumazet <dada1@cosmosbay.com>,
	Stephen Hemminger <shemminger@vyatta.com>,
	Jeff Garzik <jgarzik@pobox.com>, netdev@vger.kernel.org
To: Terry <hanfang@baidu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from robur.slu.se ([130.238.98.12]:45095 "EHLO robur.slu.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752168AbYJUMRo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 21 Oct 2008 08:17:44 -0400
In-Reply-To: <48FD97AB.1040007@baidu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Terry writes:
 > Hi 
 >     yeah. In the forwarding scenario , skb recycling should boost the 
 > performance by avoiding slowpath slub alloc/free .But if  using 
 > multiqueue hardware and assigning proper  cpu affinities  could  make it 
 > always in the fastpath of slub  alloc/free, which is faster?

 For perfect setup with monotone work like forwarding you can make the skb 
 recycling a little faster.

 If you have many active NIC's and the recycling list is per device the situation
 it's probably different...

 Cheers.
						--ro
 
