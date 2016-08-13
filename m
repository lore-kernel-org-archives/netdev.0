From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next v5 0/3] Add test_current_task_under_cgroup bpf
 helper and test
Date: Fri, 12 Aug 2016 21:50:00 -0700 (PDT)
Message-ID: <20160812.215000.1068569281494216770.davem@davemloft.net>
References: <20160812155433.GA12838@ircssh.c.rugged-nimbus-611.internal>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, alexei.starovoitov@gmail.com,
	daniel@iogearbox.net, tj@kernel.org
To: sargun@sargun.me
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:57207 "EHLO
	shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750866AbcHMEuD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 13 Aug 2016 00:50:03 -0400
In-Reply-To: <20160812155433.GA12838@ircssh.c.rugged-nimbus-611.internal>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Sargun Dhillon <sargun@sargun.me>
Date: Fri, 12 Aug 2016 08:54:35 -0700

> This patchset includes a helper and an example to determine whether the probe is
> currently executing in the context of a specific cgroup based on a cgroup bpf
> map / array. The helper checks the cgroupsv2 hierarchy based on the handle in
> the map and if the current cgroup is equal to it, or a descendant of it. The
> helper was tested with the example program, and it was verified that the correct
> behaviour occurs in the interrupt context.
> 
> In an earlier version of this patchset I had added an "opensnoop"-like tool, and
> I realized I was basically reimplementing a lot of the code that already exists
> in the bcc repo. So, instead I decided to write a test that creates a new mount
> namespace, mounts up the cgroupv2 hierarchy, and does some basic tests.  I used
> the sync syscall as a canary for these tests because it's a simple, 0-arg
> syscall. Once this patch is accepted, adding support to opensnoop will be easy.
> 
> I also added a task_under_cgroup_hierarchy function in cgroups.h, as this
> pattern is used in a couple places. Converting those can be done in a later
> patchset.
> 
> Thanks to Alexei, Tejun, and Daniel for providing review.
> 
> v1->v2: Clean up
> v2->v3: Move around ifdefs out of *.c files, add an "integration" test
> v3->v4: De-genercize arraymap fetching function;
> 	rename helper from in_cgroup to under_cgroup (makes much more sense)
> 	Split adding cgroups task_under_cgroup_hierarchy function
> v4->v5: Fix formatting

Series applied, thanks.
