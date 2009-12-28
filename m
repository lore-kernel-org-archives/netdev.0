From: Li Zefan <lizf@cn.fujitsu.com>
Subject: Re: [PATCH 3/4] cgroups: net_cls as module
Date: Mon, 28 Dec 2009 14:34:12 +0800
Message-ID: <4B385164.9070704@cn.fujitsu.com>
References: <20091221203253.GA5683@andrew.cmu.edu> <20091221203704.GD5683@andrew.cmu.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org,
	containers@lists.linux-foundation.org, akpm@linux-foundation.org,
	menage@google.com,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Ben Blum <bblum@andrew.cmu.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:55970 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751198AbZL1GeT (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 28 Dec 2009 01:34:19 -0500
In-Reply-To: <20091221203704.GD5683@andrew.cmu.edu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> Allows the net_cls cgroup subsystem to be compiled as a module
> 
> From: Ben Blum <bblum@andrew.cmu.edu>
> 
> This patch modifies net/sched/cls_cgroup.c to allow the net_cls subsystem to
> be optionally compiled as a module instead of builtin. The cgroup_subsys
> struct is moved around a bit to allow the subsys_id to be either declared as a
> compile-time constant by the cgroup_subsys.h include in cgroup.h, or, if it's
> a module, initialized within the struct by cgroup_load_subsys.
> 
> Signed-off-by: Ben Blum <bblum@andrew.cmu.edu>

Acked-by: Li Zefan <lizf@cn.fujitsu.com>

But can we reorder this patch as the last patch?


