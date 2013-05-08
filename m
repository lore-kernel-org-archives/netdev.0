From: PJ Waskiewicz <peter.p.waskiewicz.jr@linux.intel.com>
Subject: Re: [PATCH] gso: Handle Trans-Ether-Bridging protocol in skb_network_protocol()
Date: Wed, 08 May 2013 00:42:49 -0700
Message-ID: <518A01F9.8090403@linux.intel.com>
References: <1367995267-23443-1-git-send-email-pshelar@nicira.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Eric Dumazet <eric.dumazet@gmail.com>,
	Cong Wang <amwang@redhat.com>,
	"David S. Miller" <davem@davemloft.net>
To: Pravin B Shelar <pshelar@nicira.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:15284 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750830Ab3EHHmu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 8 May 2013 03:42:50 -0400
In-Reply-To: <1367995267-23443-1-git-send-email-pshelar@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/7/2013 11:41 PM, Pravin B Shelar wrote:
> Rather than having logic to calculate inner protocol in every
> tunnel gso handler move it to gso code. This simplifies code.

Moving code that isn't used on a regular basis to hotpath for most 
networking to simplify code isn't always a good thing.

Have you run tests on non-tunneled streams using GSO to make sure there 
isn't an adverse impact to performance due to the new, untaken branch?

-PJ
