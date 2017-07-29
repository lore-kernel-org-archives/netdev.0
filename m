From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net] bpf: don't indicate success when copy_from_user
 fails
Date: Sat, 29 Jul 2017 14:29:27 -0700 (PDT)
Message-ID: <20170729.142927.2190618754602693982.davem@davemloft.net>
References: <af76c90679bef1488ffb97b9b80f250b6738db57.1501182003.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: kafai@fb.com, alexei.starovoitov@gmail.com, netdev@vger.kernel.org
To: daniel@iogearbox.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:42146 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751530AbdG2V33 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 29 Jul 2017 17:29:29 -0400
In-Reply-To: <af76c90679bef1488ffb97b9b80f250b6738db57.1501182003.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Daniel Borkmann <daniel@iogearbox.net>
Date: Thu, 27 Jul 2017 21:02:46 +0200

> err in bpf_prog_get_info_by_fd() still holds 0 at that time from prior
> check_uarg_tail_zero() check. Explicitly return -EFAULT instead, so
> user space can be notified of buggy behavior.
> 
> Fixes: 1e2709769086 ("bpf: Add BPF_OBJ_GET_INFO_BY_FD")
> Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>

Applied, thanks.
