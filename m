From: Tejun Heo <tj@kernel.org>
Subject: Re: [PATCH net-next v4 1/3] cgroup: Add task_under_cgroup_hierarchy
 cgroup inline function to headers
Date: Fri, 12 Aug 2016 09:26:38 -0400
Message-ID: <20160812132638.GK2695@mtj.duckdns.org>
References: <20160812031444.GA2069@ircssh.c.rugged-nimbus-611.internal>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, alexei.starovoitov@gmail.com,
	daniel@iogearbox.net
To: Sargun Dhillon <sargun@sargun.me>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f196.google.com ([209.85.216.196]:36615 "EHLO
	mail-qt0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751982AbcHLN0l (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 12 Aug 2016 09:26:41 -0400
Received: by mail-qt0-f196.google.com with SMTP id u25so968956qtb.3
        for <netdev@vger.kernel.org>; Fri, 12 Aug 2016 06:26:40 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <20160812031444.GA2069@ircssh.c.rugged-nimbus-611.internal>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 11, 2016 at 08:14:45PM -0700, Sargun Dhillon wrote:
> This commit adds an inline function to cgroup.h to check whether a given
> task is under a given cgroup hierarchy. This is to avoid having to put
> ifdefs in .c files to gate access to cgroups. When cgroups are disabled
> this always returns true.
> 
> Signed-off-by: Sargun Dhillon <sargun@sargun.me>
> Cc: Alexei Starovoitov <ast@kernel.org>
> Cc: Daniel Borkmann <daniel@iogearbox.net>
> Cc: Tejun Heo <tj@kernel.org>

Acked-by: Tejun Heo <tj@kernel.org>

Please feel free to route with other patches.  If it'd be better to
route this through the cgroup tree, please let me know.

Thanks.

-- 
tejun
