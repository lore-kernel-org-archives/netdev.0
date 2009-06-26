From: Xiao Guangrong <xiaoguangrong@cn.fujitsu.com>
Subject: Re: [PATCH v2] ftrace: change the export format of trace_kfree_skb()
Date: Fri, 26 Jun 2009 09:24:42 +0800
Message-ID: <4A44235A.4090503@cn.fujitsu.com>
References: <20090610072618.GA6016@nowhere>	<4A39B3E4.6060004@cn.fujitsu.com>	<20090618103538.GA8978@hmsreliant.think-freely.org> <20090623.235838.129947362.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: nhorman@tuxdriver.com, mingo@elte.hu, fweisbec@gmail.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	rostedt@goodmis.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:53668 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752126AbZFZBYa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Jun 2009 21:24:30 -0400
In-Reply-To: <20090623.235838.129947362.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



David Miller wrote:
> FWIW there are parts I don't like about this change.
> 
> It's just the show_protocol_name() bit, it's designed to always be
> out of date.
> 
> Nobody is going to look at trace/events/skb.h when they add a new
> ETH_P_* value.
> 
> We could make some include/linux/eth_protos.def file, that has
> lines like:
> 
> ETHERNET_PROTOCOL(ETH_P_FOO, N)
> 
> then headers that want to instantiate something like the usual
> ETH_P_FOO defines or this symbolic printing table define
> "ETHERNET_PROTOCOL" to a suitable macro and then include
> linux/eth_protos.def to make the expansions.
> 

Thanks for your review and your nice solution.
I will fix it in next version. ;-)

Thanks,
Xiao

> 
