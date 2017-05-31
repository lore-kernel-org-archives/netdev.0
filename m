From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH v2 net-next 0/8] Introduce bpf ID
Date: Wed, 31 May 2017 19:35:18 -0400 (EDT)
Message-ID: <20170531.193518.1564008102407413329.davem@davemloft.net>
References: <cover.1496256722.git.kafai@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ast@fb.com, daniel@iogearbox.net,
        kernel-team@fb.com
To: kafai@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:46160 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751033AbdEaXf0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 31 May 2017 19:35:26 -0400
In-Reply-To: <cover.1496256722.git.kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Martin KaFai Lau <kafai@fb.com>
Date: Wed, 31 May 2017 11:58:54 -0700

> This patch series:
> 1) Introduce ID for both bpf_prog and bpf_map.
> 2) Add bpf commands to iterate the prog IDs and map
>    IDs of the system.
> 3) Add bpf commands to get a prog/map fd from an ID
> 4) Add bpf command to get prog/map info from a fd.
>    The prog/map info is a jump start in this patchset
>    and it is not meant to be a complete list.  They can
>    be extended in the future patches.
> 
> v2:
> Compiler warning fixes:
> - Remove lockdep_is_held() usage.  Add comment
>   to explain the lock situation instead.
> - Add static for idr related variables
> - Add __user to the uattr param in bpf_prog_get_info_by_fd()
>   and bpf_map_get_info_by_fd().

Series applied, thanks Martin.
