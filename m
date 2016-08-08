From: Denys Fedoryshchenko <nuclearcat@nuclearcat.com>
Subject: Re: 4.6.3, pppoe + shaper workload, skb_panic / skb_push /
 ppp_start_xmit
Date: Mon, 08 Aug 2016 14:25:00 +0300
Message-ID: <0776d5f55356ba0ed4400d46e5e52088@nuclearcat.com>
References: <c72d23549eaa7aadee1a66a6bb788a4a@nuclearcat.com>
 <CAM_iQpWuCw6Bgm=1BWMkoFkuav5xV+FyKPq0Ef+3N_qpQqv=AA@mail.gmail.com>
 <20160728110948.GA3046@alphalink.fr>
 <e6cb92be01af6190350b9b3765bee6e3@nuclearcat.com>
 <20160801205908.GD3031@alphalink.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII;
 format=flowed
Content-Transfer-Encoding: 7bit
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Guillaume Nault <g.nault@alphalink.fr>
Return-path: <netdev-owner@vger.kernel.org>
Received: from nuclearcat.com ([144.76.183.226]:55326 "EHLO nuclearcat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752014AbcHHLZE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Aug 2016 07:25:04 -0400
In-Reply-To: <20160801205908.GD3031@alphalink.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2016-08-01 23:59, Guillaume Nault wrote:
> Do you still have the vmlinux file with debug symbols that generated
> this panic?
Sorry for delay, i didn't had same image on all servers and probably i 
found cause of panic, but still testing on several servers.
If i remove SFQ qdisc from ppp shapers, servers not rebooting anymore.
But still i need around 2 days to make sure that's the reason.
