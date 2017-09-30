From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next] bpf: Fix compiler warning on info.map_ids for
 32bit platform
Date: Sat, 30 Sep 2017 21:05:24 +0200
Message-ID: <59CFEAF4.20600@iogearbox.net>
References: <20170929175217.437830-1-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <ast@fb.com>, kernel-team@fb.com
To: Martin KaFai Lau <kafai@fb.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:40028 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751099AbdI3TF0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 30 Sep 2017 15:05:26 -0400
In-Reply-To: <20170929175217.437830-1-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/29/2017 07:52 PM, Martin KaFai Lau wrote:
> This patch uses u64_to_user_ptr() to cast info.map_ids to a userspace ptr.
> It also tags the user_map_ids with '__user' for sparse check.
>
> Fixes: cb4d2b3f03d8 ("bpf: Add name, load_time, uid and map_ids to bpf_prog_info")
> Signed-off-by: Martin KaFai Lau <kafai@fb.com>

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
