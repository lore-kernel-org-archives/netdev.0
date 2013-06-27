From: Cong Wang <amwang@redhat.com>
Subject: Re: [Patch net] ipv6,mcast: always hold idev->lock before mca_lock
Date: Thu, 27 Jun 2013 11:09:44 +0800
Message-ID: <1372302584.26333.2.camel@cr0>
References: <1367998914-26423-1-git-send-email-amwang@redhat.com>
	 <20130626225809.GB26180@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, dingtianhong <dingtianhong@huawei.com>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	"David S. Miller" <davem@davemloft.net>
To: Hannes Frederic Sowa <hannes@stressinduktion.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:63349 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751522Ab3F0DJ7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 26 Jun 2013 23:09:59 -0400
In-Reply-To: <20130626225809.GB26180@order.stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2013-06-27 at 00:58 +0200, Hannes Frederic Sowa wrote:
> I do confirm that if this last hunk is applied the idev->addr_list
> traversal
> is safe.
> 
> Please let me know if no one is working on this, I would rebase it
> then. 

I will rebase my patch on latest net-next. I am assuming this patch
looks good to you...

Thanks!
