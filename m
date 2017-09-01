From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v3 net-next 0/7] bpf: Add option to set mark and
 priority in cgroup sock programs
Date: Fri, 01 Sep 2017 06:06:09 +0100 (WEST)
Message-ID: <20170901.060609.1844094785534959963.davem@davemloft.net>
References: <1504217150-16151-1-git-send-email-dsahern@gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, daniel@iogearbox.net, ast@kernel.org
To: dsahern@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:37846 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750759AbdIAFGN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 1 Sep 2017 01:06:13 -0400
In-Reply-To: <1504217150-16151-1-git-send-email-dsahern@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: David Ahern <dsahern@gmail.com>
Date: Thu, 31 Aug 2017 15:05:43 -0700

> Add option to set mark and priority in addition to bound device for newly
> created sockets. Also, allow the bpf programs to use the get_current_uid_gid
> helper meaning socket marks, priority and device can be set based on the
> uid/gid of the running process.
> 
> Sample programs are updated to demonstrate the new options.
> 
> v3
> - no changes to Patches 1 and 2 which Alexei acked in previous versions
> - dropped change related to recursive programs in a cgroup
> - updated tests per dropped patch
> 
> v2
> - added flag to control recursive behavior as requested by Alexei
> - added comment to sock_filter_func_proto regarding use of
>   get_current_uid_gid helper
> - updated test programs for recursive option

Series applied, please follow up to Daniel's feedback.

Thanks.
