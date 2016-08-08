From: Guillaume Nault <g.nault@alphalink.fr>
Subject: Re: 4.6.3, pppoe + shaper workload, skb_panic / skb_push /
 ppp_start_xmit
Date: Mon, 8 Aug 2016 23:05:41 +0200
Message-ID: <20160808210541.GI3031@alphalink.fr>
References: <c72d23549eaa7aadee1a66a6bb788a4a@nuclearcat.com>
 <CAM_iQpWuCw6Bgm=1BWMkoFkuav5xV+FyKPq0Ef+3N_qpQqv=AA@mail.gmail.com>
 <20160728110948.GA3046@alphalink.fr>
 <e6cb92be01af6190350b9b3765bee6e3@nuclearcat.com>
 <20160801205908.GD3031@alphalink.fr>
 <0776d5f55356ba0ed4400d46e5e52088@nuclearcat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Cong Wang <xiyou.wangcong@gmail.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Denys Fedoryshchenko <nuclearcat@nuclearcat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zimbra.alphalink.fr ([217.15.80.77]:52731 "EHLO
	zimbra.alphalink.fr" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750929AbcHHVFp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Aug 2016 17:05:45 -0400
Content-Disposition: inline
In-Reply-To: <0776d5f55356ba0ed4400d46e5e52088@nuclearcat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Aug 08, 2016 at 02:25:00PM +0300, Denys Fedoryshchenko wrote:
> On 2016-08-01 23:59, Guillaume Nault wrote:
> > Do you still have the vmlinux file with debug symbols that generated
> > this panic?
> Sorry for delay, i didn't had same image on all servers and probably i found
> cause of panic, but still testing on several servers.
> If i remove SFQ qdisc from ppp shapers, servers not rebooting anymore.
> 
Thanks for the feedback. I wonder which interactions between SFQ and
PPP can lead to this problem. I'll take a look.

> But still i need around 2 days to make sure that's the reason.
> 
Okay, just let me know if you can confirm that removing SFQ really
solves the problem.
