From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next 0/8] bpf: Add option to set mark and
 priority in cgroup sock programs
Date: Tue, 29 Aug 2017 14:53:40 -0700 (PDT)
Message-ID: <20170829.145340.1262408275355867443.davem@davemloft.net>
References: <1503687941-626-1-git-send-email-dsahern@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, daniel@iogearbox.net, ast@kernel.org,
        tj@kernel.org
To: dsahern@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:39850 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751440AbdH2Vxl (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2017 17:53:41 -0400
In-Reply-To: <1503687941-626-1-git-send-email-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsahern@gmail.com>
Date: Fri, 25 Aug 2017 12:05:33 -0700

> Add option to set mark and priority in addition to bound device for newly
> created sockets. Also, allow the bpf programs to use the get_current_uid_gid
> helper meaning socket marks, priority and device can be set base on the
> uid/gid of the running process.
> 
> For flexbility in deploying these programs, option is added to allow cgroups
> to be walked from current to root running any program attached. This allows
> one cgroup level to control the device a socket is bound to (e.g, a VRF) while
> cgroups can be used to set socket marks and priority.
> 
> Sample programs are updated to demonstrate the new options.
> 
> v2
> - added flag to control recursive behavior as requested by Alexei
> - added comment to sock_filter_func_proto regarding use of
>   get_current_uid_gid helper
> - updated test programs for recursive option

I'm marking this patch series as "deferred" while the semantic issues
keep getting discussed.

Thanks.
