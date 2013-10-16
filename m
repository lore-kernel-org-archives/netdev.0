From: Randy Dunlap <rdunlap@infradead.org>
Subject: Re: linux-next: Tree for Oct 16 (net/sched/em_ipset.c)
Date: Wed, 16 Oct 2013 14:48:32 -0700
Message-ID: <525F09B0.4080802@infradead.org>
References: <1381949500-501-1-git-send-email-treding@nvidia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	Mark Brown <broonie@kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Thierry Reding <thierry.reding@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from merlin.infradead.org ([205.233.59.134]:38221 "EHLO
	merlin.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760758Ab3JPVsf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Oct 2013 17:48:35 -0400
In-Reply-To: <1381949500-501-1-git-send-email-treding@nvidia.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/16/13 11:51, Thierry Reding wrote:
> Hi all,
> 
> I've uploaded today's linux-next tree to the master branch of the
> repository below:
> 
>         git://gitorious.org/thierryreding/linux-next.git
> 
> A next-20131016 tag is also provided for convenience.
> 
> Gained two new conflicts, but nothing too exciting. x86 and ARM default
> configurations as well as the x86 allmodconfig mostly build fine on the
> final tree. There was a failure for the ARM at91x40_defconfig, but the
> proper fix wasn't immediately obvious to me, so I've left it broken for
> now.

on i386, when CONFIG_NET_NS is not enabled:

net/sched/em_ipset.c: In function 'em_ipset_change':
net/sched/em_ipset.c:27:36: error: 'struct net_device' has no member named 'nd_net'
net/sched/em_ipset.c: In function 'em_ipset_destroy':
net/sched/em_ipset.c:49:34: error: 'struct net_device' has no member named 'nd_net'


-- 
~Randy
