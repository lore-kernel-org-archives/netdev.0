From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH net-next 1/2] bpf: Fix test_bpf_obj_id() when the
 bpf_jit_enable sysctl is diabled
Date: Fri, 09 Jun 2017 15:15:44 -0400 (EDT)
Message-ID: <20170609.151544.817423446769306846.davem@davemloft.net>
References: <20170609053017.2909855-1-kafai@fb.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ast@fb.com, daniel@iogearbox.net,
        yhs@fb.com, kernel-team@fb.com
To: kafai@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from shards.monkeyblade.net ([184.105.139.130]:37502 "EHLO
        shards.monkeyblade.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751561AbdFITPq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Jun 2017 15:15:46 -0400
In-Reply-To: <20170609053017.2909855-1-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Martin KaFai Lau <kafai@fb.com>
Date: Thu, 8 Jun 2017 22:30:16 -0700

> test_bpf_obj_id() should not expect a non zero jited_prog_len
> to be returned by bpf_obj_get_info_by_fd() when
> net.core.bpf_jit_enable is 0.
> 
> The patch checks for net.core.bpf_jit_enable and
> has different expectation on jited_prog_len.
> 
> This patch also removes the pwd.h header which I forgot
> to remove after making changes.
> 
> Fixes: 95b9afd3987f ("bpf: Test for bpf ID")
> Reported-by: Yonghong Song <yhs@fb.com>
> Signed-off-by: Martin KaFai Lau <kafai@fb.com>

Applied, but please in the future provide a proper header posting
with Subject "[PATCH net-next 0/N] ...".

Thanks.
