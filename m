From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next] bpf: Fix compiler warning on info.map_ids for
 32bit platform
Date: Sun, 01 Oct 2017 04:11:04 +0100 (WEST)
Message-ID: <20171001.041104.435845954802680756.davem@davemloft.net>
References: <20170929175217.437830-1-kafai@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ast@fb.com, daniel@iogearbox.net,
        kernel-team@fb.com
To: kafai@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:34216 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750730AbdJADLG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 30 Sep 2017 23:11:06 -0400
In-Reply-To: <20170929175217.437830-1-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Martin KaFai Lau <kafai@fb.com>
Date: Fri, 29 Sep 2017 10:52:17 -0700

> This patch uses u64_to_user_ptr() to cast info.map_ids to a userspace ptr.
> It also tags the user_map_ids with '__user' for sparse check.
> 
> Fixes: cb4d2b3f03d8 ("bpf: Add name, load_time, uid and map_ids to bpf_prog_info")
> Signed-off-by: Martin KaFai Lau <kafai@fb.com>

Applied.
