From: Peter Zijlstra <peterz@infradead.org>
Subject: Re: 2.6.35-rc2-git1 - include/linux/cgroup.h:534 invoked
 rcu_dereference_check() without protection!
Date: Wed, 09 Jun 2010 17:24:28 +0200
Message-ID: <1276097068.1745.13.camel@laptop>
References: <AANLkTin2pPqOUx--9fIX3BH3e-cU6oCRufijcx_4ozx5@mail.gmail.com>
	 <20100608001929.GF2387@linux.vnet.ibm.com>
	 <AANLkTikl13cJNuU32JzRarrUnoh5DYHr-Tbnv9B-UjsG@mail.gmail.com>
	 <1275986441.5408.111.camel@twins>
	 <AANLkTimXVlgzHivCQberLdrFP8BH_nJzt8_ozUNHG_aI@mail.gmail.com>
	 <1276004075.2987.208.camel@twins>
	 <AANLkTil6ucLZ0A6tWx-OQt_2EeKnx8nSx6rIg2t1L2t5@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 8BIT
Cc: paulmck@linux.vnet.ibm.com, Vivek Goyal <vgoyal@redhat.com>,
	Eric Paris <eparis@redhat.com>,
	Lai Jiangshan <laijs@cn.fujitsu.com>,
	Ingo Molnar <mingo@elte.hu>,
	LKML <linux-kernel@vger.kernel.org>, nauman@google.com,
	eric.dumazet@gmail.com, netdev@vger.kernel.org,
	Jens Axboe <jens.axboe@oracle.com>,
	Gui Jianfeng <guijianfeng@cn.fujitsu.com>,
	Li Zefan <lizf@cn.fujitsu.com>,
	Johannes Berg <johannes@sipsolutions.net>
To: Miles Lane <miles.lane@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <AANLkTil6ucLZ0A6tWx-OQt_2EeKnx8nSx6rIg2t1L2t5@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2010-06-09 at 11:11 -0400, Miles Lane wrote:
> 
> Sorry.  I misunderstood this message when I first read it.  I didn't
> realize this message include a new version of the patch.
> Anyhow, I just tried to apply the patch to 2.6.35-rc2-git3 and got this:
> 
> # patch -p1 -l -F 20 --dry-run < ../5.patch
> patching file include/linux/cgroup.h
> patching file kernel/sched.c
> Hunk #1 succeeded at 306 with fuzz 1.
> Hunk #3 FAILED at 4462.
> Hunk #4 succeeded at 4487 with fuzz 3.
> 1 out of 4 hunks FAILED -- saving rejects to file kernel/sched.c.rej

Weird.. it seems to apply without trouble to Linus' git tree.

root@twins:/usr/src/linux-2.6# git checkout -f origin/master
HEAD is now at 84f7586... Merge branch 'for-linus' of git://git.kernel.org/pub/scm/linux/kernel/git/ieee1394/linux1394-2.6
root@twins:/usr/src/linux-2.6# quilt push
Applying patch patches/sched-rcu-validation.patch
patching file include/linux/cgroup.h
patching file kernel/sched.c

Now at patch patches/sched-rcu-validation.patch
root@twins:/usr/src/linux-2.6# git describe
v2.6.35-rc2-54-g84f7586
