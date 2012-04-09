From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH v3 2/2] cgroup: get rid of populate for memcg
Date: Mon, 9 Apr 2012 15:42:46 -0700
Message-ID: <20120409224246.GA11614@dhcp-172-17-108-109.mtv.corp.google.com>
References: <1334010994-23301-1-git-send-email-glommer@parallels.com>
 <1334010994-23301-3-git-send-email-glommer@parallels.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, cgroups@vger.kernel.org,
	Li Zefan <lizefan@huawei.com>, kamezawa.hiroyu@jp.fujitsu.com,
	Johannes Weiner <hannes@cmpxchg.org>,
	Michal Hocko <mhocko@suse.cz>
To: Glauber Costa <glommer@parallels.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:41567 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752507Ab2DIWmv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 9 Apr 2012 18:42:51 -0400
Content-Disposition: inline
In-Reply-To: <1334010994-23301-3-git-send-email-glommer@parallels.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Apr 09, 2012 at 07:36:34PM -0300, Glauber Costa wrote:
> The last man standing justifying the need for populate() is the
> sock memcg initialization functions. Now that we are able to pass
> a struct mem_cgroup instead of a struct cgroup to the socket
> initialization, there is nothing that stops us from initializing
> everything in create().
> 
> Signed-off-by: Glauber Costa <glommer@parallels.com>
> CC: Tejun Heo <tj@kernel.org>
> CC: Li Zefan <lizefan@huawei.com>
> CC: Kamezawa Hiroyuki <kamezawa.hiroyu@jp.fujitsu.com>
> CC: Johannes Weiner <hannes@cmpxchg.org>
> CC: Michal Hocko <mhocko@suse.cz>

Will apply once memcg maintainers ack.

Thanks.

-- 
tejun
