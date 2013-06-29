From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [Patch net-next v2] ipv6,mcast: always hold idev->lock before mca_lock
Date: Sat, 29 Jun 2013 16:40:52 +0200
Message-ID: <20130629144052.GB6519@order.stressinduktion.org>
References: <1372512649-7550-1-git-send-email-amwang@redhat.com> <20130629135321.GA5884@order.stressinduktion.org> <1372514981.29178.10.camel@cr0>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, dingtianhong <dingtianhong@huawei.com>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	"David S. Miller" <davem@davemloft.net>
To: Cong Wang <amwang@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s15338416.onlinehome-server.info ([87.106.68.36]:45342 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752169Ab3F2Ok4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 29 Jun 2013 10:40:56 -0400
Content-Disposition: inline
In-Reply-To: <1372514981.29178.10.camel@cr0>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jun 29, 2013 at 10:09:41PM +0800, Cong Wang wrote:
> On Sat, 2013-06-29 at 15:53 +0200, Hannes Frederic Sowa wrote:
> > 
> > If we export __ipv6_get_lladdr in a header, shouldn't we also EXPORT_SYMBOL
> > it? I am not sure but would have done so.
> 
> Why? It is used only by IPv6 module itself.

Yes, you are right. We don't export ipv6_get_lladdr either, so:

Acked-by: Hannes Frederic Sowa <hannes@stressinduktion.org>

Thanks,

  Hannes
