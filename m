From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net] ipv6: ip6_append_data_mtu did not care about pmtudisc and frag_size
Date: Tue, 2 Jul 2013 07:13:21 +0200
Message-ID: <20130702051321.GB9877@order.stressinduktion.org>
References: <20130701181742.GB8937@order.stressinduktion.org> <51D23F0E.3030104@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: "yoshfuji@linux-ipv6.org" <yoshfuji@linux-ipv6.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Gao feng <gaofeng@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s15338416.onlinehome-server.info ([87.106.68.36]:49070 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751442Ab3GBFNX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jul 2013 01:13:23 -0400
Content-Disposition: inline
In-Reply-To: <51D23F0E.3030104@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jul 02, 2013 at 10:46:38AM +0800, Gao feng wrote:
> On 07/02/2013 02:17 AM, Hannes Frederic Sowa wrote:
> No need to pass ipv6_pinfo to ip6_append_data_mtu, the below is enough.
> 
> *mtu = min(*mtu, (np->pmtudisc == IPV6_PMTUDISC_DO) ?
> 				rt->dst.dev->mtu :
> 				dst_mtu(rt->dst.path);
> 
> This patch looks good go me.
> 
> Acked-by: Gao feng <gaofeng@cn.fujitsu.com>
> 
> Thanks!

Thanks for your feedback, I will incooperate it in my next version of
the patch. Actually, I seem to have done an error in the above code,
i need to replace IPV6_PMTUDISC_DO with IPV6_PMTUDISC_WANT. Does your
Acked-by still hold?

Thanks,

  Hannes
