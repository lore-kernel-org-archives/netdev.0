From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next 1/2] bpf: Fix test_bpf_obj_id() when the bpf_jit_enable
 sysctl is diabled
Date: Fri, 09 Jun 2017 12:06:29 +0200
Message-ID: <593A7325.2070202@iogearbox.net>
References: <20170609053017.2909855-1-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <ast@fb.com>, Yonghong Song <yhs@fb.com>,
        kernel-team@fb.com
To: Martin KaFai Lau <kafai@fb.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:35242 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751524AbdFIKGc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 9 Jun 2017 06:06:32 -0400
In-Reply-To: <20170609053017.2909855-1-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/09/2017 07:30 AM, Martin KaFai Lau wrote:
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

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
