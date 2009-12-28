From: Li Zefan <lizf@cn.fujitsu.com>
Subject: Re: [PATCH 4/4] cgroups: subsystem module unloading
Date: Mon, 28 Dec 2009 14:36:55 +0800
Message-ID: <4B385207.8070305@cn.fujitsu.com>
References: <20091221203253.GA5683@andrew.cmu.edu> <20091221203800.GE5683@andrew.cmu.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	containers@lists.linux-foundation.org, akpm@linux-foundation.org,
	Paul Menage <menage@google.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Ben Blum <bblum@andrew.cmu.edu>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1751859AbZL1GhG@vger.kernel.org>
In-Reply-To: <20091221203800.GE5683@andrew.cmu.edu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

> Provides support for unloading modular subsystems.
> 
> From: Ben Blum <bblum@andrew.cmu.edu>
> 
> This patch adds a new function cgroup_unload_subsys which is to be used for
> removing a loaded subsystem during module deletion. Reference counting of the
> subsystems' modules is moved from once (at load time) to once per attached
> hierarchy (in parse_cgroupfs_options and rebind_subsystems) (i.e., 0 or 1).
> 
> It also adds a proper module_delete call in net/sched/cls_cgroup.c.
> 
> Signed-off-by: Ben Blum <bblum@andrew.cmu.edu>

Acked-by: Li Zefan <lizf@cn.fujitsu.com>

Also please fix comment style and add some blank lines properly.
