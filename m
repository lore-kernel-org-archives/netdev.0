From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCHSET v3] netfilter, cgroup: implement cgroup2 path match in
 xt_cgroup
Date: Mon, 23 Nov 2015 14:58:04 -0500
Message-ID: <20151123195804.GB19072@mtj.duckdns.org>
References: <1448122441-9335-1-git-send-email-tj@kernel.org>
 <5652BC3A.1010701@bmw-carit.de>
 <5652D448.3080002@bmw-carit.de>
 <20151123155346.GE3049@mtj.duckdns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, pablo@netfilter.org, kaber@trash.net,
	kadlec@blackhole.kfki.hu, daniel@iogearbox.net,
	nhorman@tuxdriver.co, lizefan@huawei.com, hannes@cmpxchg.org,
	netdev@vger.kernel.org, netfilter-devel@vger.kernel.org,
	coreteam@netfilter.org, cgroups@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-team@fb.com, ninasc@fb.com
To: Daniel Wagner <daniel.wagner@bmw-carit.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20151123155346.GE3049@mtj.duckdns.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

On Mon, Nov 23, 2015 at 10:53:46AM -0500, Tejun Heo wrote:
> > [   11.594536] ------------[ cut here ]------------
> > [   11.595274] WARNING: CPU: 1 PID: 1 at kernel/cgroup_pids.c:97 pids_cancel.constprop.6+0x31/0x40()
> > [   11.595958] Modules linked in:
> > [   11.596199] CPU: 1 PID: 1 Comm: systemd Not tainted 4.4.0-rc1+ #196
> > [   11.596689] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS rel-1.8.2-0-g33fbe13 by qemu-project.org 04/01/2014
> > [   11.597632]  ffffffff81f66d8b ffff88007c04bb90 ffffffff8155ccdc 0000000000000000
> > [   11.598234]  ffff88007c04bbc8 ffffffff810de202 ffff8800793dda00 ffff88007a096800
> > [   11.598877]  ffff88007c04bc80 ffff88007a6b6200 0000000000000001 ffff88007c04bbd8
> > [   11.599547] Call Trace:
> > [   11.599784]  [<ffffffff8155ccdc>] dump_stack+0x4e/0x82
> > [   11.600197]  [<ffffffff810de202>] warn_slowpath_common+0x82/0xc0
> > [   11.600705]  [<ffffffff810de2fa>] warn_slowpath_null+0x1a/0x20
> > [   11.601208]  [<ffffffff8118e261>] pids_cancel.constprop.6+0x31/0x40
> > [   11.601764]  [<ffffffff8118e32d>] pids_can_attach+0x6d/0xf0
> 
> Yeah, this is a known problem regarding css's lifetime.  Working on
> it.  The earlier dump, I think, is likely to have been caused by the
> same issue.

Just posted the fix for this issue.  Can you please verify the fix?

 http://lkml.kernel.org/g/20151123195541.GA19072@mtj.duckdns.org

Thanks a lot!

-- 
tejun
