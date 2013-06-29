From: Cong Wang <amwang@redhat.com>
Subject: Re: [Patch net-next v2] ipv6,mcast: always hold idev->lock before
 mca_lock
Date: Sat, 29 Jun 2013 22:09:41 +0800
Message-ID: <1372514981.29178.10.camel@cr0>
References: <1372512649-7550-1-git-send-email-amwang@redhat.com>
	 <20130629135321.GA5884@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dingtianhong <dingtianhong@huawei.com>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	"David S. Miller" <davem@davemloft.net>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:62009 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750950Ab3F2OJx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 29 Jun 2013 10:09:53 -0400
In-Reply-To: <20130629135321.GA5884@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2013-06-29 at 15:53 +0200, Hannes Frederic Sowa wrote:
> 
> If we export __ipv6_get_lladdr in a header, shouldn't we also EXPORT_SYMBOL
> it? I am not sure but would have done so.

Why? It is used only by IPv6 module itself.
