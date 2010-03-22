From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [net-next-2.6 PATCH] bonding: flush unicast and multicast lists
 when changing type
Date: Mon, 22 Mar 2010 13:26:45 +0100
Message-ID: <20100322122644.GA2780@psychotron.lab.eng.brq.redhat.com>
References: <20100319140023.GC2811@psychotron.redhat.com>
 <20100321.183220.220048937.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, fubar@us.ibm.com,
	bonding-devel@lists.sourceforge.net
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:44911 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754087Ab0CVM05 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 22 Mar 2010 08:26:57 -0400
Content-Disposition: inline
In-Reply-To: <20100321.183220.220048937.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Mon, Mar 22, 2010 at 02:32:20AM CET, davem@davemloft.net wrote:
>From: Jiri Pirko <jpirko@redhat.com>
>Date: Fri, 19 Mar 2010 15:00:23 +0100
>
>> After the type change, addresses in unicast and multicast lists wouldn't make
>> sense, not to mention possible different lenghts. So flush both lists here.
>> 
>> Note "dev_addr_discard" will be very soon replaced by "dev_mc_flush" (once
>> mc_list conversion will be done).
>> 
>> Signed-off-by: Jiri Pirko <jpirko@redhat.com>
>
>Applied, but maybe these should be EXPORT_SYMBOL_GPL?  Just
>asking...

I would keep them EXPORT_SYMBOL as other uc/mc list functions...
