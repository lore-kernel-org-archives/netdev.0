From: Tejun Heo <tj@kernel.org>
Subject: Re: vhost_dev_cleanup() crash: BUG: unable to handle kernel NULL
 pointer dereference
Date: Tue, 31 Aug 2010 14:20:54 +0200
Message-ID: <4C7CF3A6.5060200@kernel.org>
References: <20100831075705.GA4710@elte.hu>	 <1283251801.2550.53.camel@edumazet-laptop> <20100831111413.GB12853@elte.hu> <1283256357.2550.61.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: Ingo Molnar <mingo@elte.hu>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	"Michael S. Tsirkin" <mst@redhat.com>,
	"David S. Miller" <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from hera.kernel.org ([140.211.167.34]:56055 "EHLO hera.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1755828Ab0HaMVN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 31 Aug 2010 08:21:13 -0400
In-Reply-To: <1283256357.2550.61.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/31/2010 02:05 PM, Eric Dumazet wrote:
> Just in case, I resubmit the patch, clearing dev->worker, because I am
> not sure if vhost_dev_cleanup() can be run several times on same struct
> vhost_dev. Patch is needed even if you add this check in kthread_stop()
> 
> [PATCH v2] vhost: stop worker only if created
> 
> Its currently illegal to call kthread_stop(NULL)
> 
> Reported-by: Ingo Molnar <mingo@elte.hu>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>

Acked-by: Tejun Heo <tj@kernel.org>

Thanks.

-- 
tejun
