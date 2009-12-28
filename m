From: Ben Blum <bblum@andrew.cmu.edu>
Subject: Re: [PATCH 3/4] cgroups: net_cls as module
Date: Mon, 28 Dec 2009 07:37:34 -0500
Message-ID: <20091228123734.GA4824@andrew.cmu.edu>
References: <20091221203253.GA5683@andrew.cmu.edu> <20091221203704.GD5683@andrew.cmu.edu> <4B385164.9070704@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org,
	containers@lists.linux-foundation.org, akpm@linux-foundation.org,
	menage@google.com,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	bblum@andrew.cmu.edu
To: Li Zefan <lizf@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from RELAY.ANDREW.CMU.EDU ([128.2.10.85]:60020 "EHLO
	relay.andrew.cmu.edu" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751514AbZL1MiA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Dec 2009 07:38:00 -0500
Content-Disposition: inline
In-Reply-To: <4B385164.9070704@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 28, 2009 at 02:34:12PM +0800, Li Zefan wrote:
> > Allows the net_cls cgroup subsystem to be compiled as a module
> > 
> > From: Ben Blum <bblum@andrew.cmu.edu>
> > 
> > This patch modifies net/sched/cls_cgroup.c to allow the net_cls subsystem to
> > be optionally compiled as a module instead of builtin. The cgroup_subsys
> > struct is moved around a bit to allow the subsys_id to be either declared as a
> > compile-time constant by the cgroup_subsys.h include in cgroup.h, or, if it's
> > a module, initialized within the struct by cgroup_load_subsys.
> > 
> > Signed-off-by: Ben Blum <bblum@andrew.cmu.edu>
> 
> Acked-by: Li Zefan <lizf@cn.fujitsu.com>
> 
> But can we reorder this patch as the last patch?

that does make a bit more sense, saving the unloading patch from having
to touch cls_cgroup.c to add an unload_subsys() call. will do.
