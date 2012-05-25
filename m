From: Glauber Costa <glommer@parallels.com>
Subject: [PATCH v7 0/2] fixes for sock memcg static branch disablement
Date: Fri, 25 May 2012 13:32:06 +0400
Message-ID: <1337938328-11537-1-git-send-email-glommer@parallels.com>
Cc: <linux-mm@kvack.org>, <cgroups@vger.kernel.org>,
	<devel@openvz.org>, <kamezawa.hiroyu@jp.fujitsu.com>,
	<netdev@vger.kernel.org>, Tejun Heo <tj@kernel.org>,
	Li Zefan <lizefan@huawei.com>,
	David Miller <davem@davemloft.net>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailhub.sw.ru ([195.214.232.25]:9884 "EHLO relay.sw.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752519Ab2EYJeN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 25 May 2012 05:34:13 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Andrew,

I believe this one addresses all of your previous comments.

Besides merging your patch, I tried to improve the comments so they would
be more informative. 

The first patch, I believe, is already merged at your tree. But I am including
it here for completeness. I had no changes since last submission, so feel free
to pick the second - or if there are still missing changes you'd like to see,
point me to them.

Thanks

Glauber Costa (2):
  Always free struct memcg through schedule_work()
  decrement static keys on real destroy time

 include/net/sock.h        |   22 ++++++++++++++++++
 mm/memcontrol.c           |   55 ++++++++++++++++++++++++++++++++++----------
 net/ipv4/tcp_memcontrol.c |   34 ++++++++++++++++++++++-----
 3 files changed, 91 insertions(+), 20 deletions(-)

-- 
1.7.7.6
