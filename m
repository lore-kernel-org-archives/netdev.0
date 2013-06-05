From: Eliezer Tamir <eliezer.tamir@linux.intel.com>
Subject: Re: [PATCH v9 net-next 2/7] net: add low latency socket poll
Date: Wed, 05 Jun 2013 18:30:56 +0300
Message-ID: <51AF59B0.6080101@linux.intel.com>
References: <20130605103400.11172.49099.stgit@ladj378.jer.intel.com>  <20130605103421.11172.82925.stgit@ladj378.jer.intel.com> <1370445714.24311.268.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Don Skidmore <donald.c.skidmore@intel.com>,
	e1000-devel@lists.sourceforge.net,
	Willem de Bruijn <willemb@google.com>,
	Ben Hutchings <bhutchings@solarflare.com>,
	Andi Kleen <andi@firstfloor.org>, HPA <hpa@zytor.com>,
	Eilon Greenstien <eilong@broadcom.com>,
	Or Gerlitz <or.gerlitz@gmail.com>,
	Amir Vadai <amirv@mellanox.com>,
	Eliezer Tamir <eliezer@tamir.org.il>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:50711 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756479Ab3FEPbI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 5 Jun 2013 11:31:08 -0400
In-Reply-To: <1370445714.24311.268.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


On 05/06/2013 18:21, Eric Dumazet wrote:
> On Wed, 2013-06-05 at 13:34 +0300, Eliezer Tamir wrote:
>
>
> This is probably too big to be inlined, and nonblock should be a bool


> It would also make sense to give end_time as a parameter, so that the
> polling() code could really give  a end_time for the whole duration of
> poll().
>
> (You then should test can_poll_ll(end_time) _before_ call to
> ndo_ll_poll())

how would you handle a nonblocking operation in that case?
I guess if we have a socket option, then we don't need to handle none 
blocking any diffrent, since the user specified exactly how much time to 
waste polling. right?
