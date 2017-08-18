From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next] bpf: Fix map-in-map checking in the verifier
Date: Fri, 18 Aug 2017 10:10:40 +0200
Message-ID: <5996A100.8070601@iogearbox.net>
References: <20170818011443.562793-1-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexei Starovoitov <ast@fb.com>, kernel-team@fb.com,
        John Fastabend <john.fastabend@gmail.com>
To: Martin KaFai Lau <kafai@fb.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:41728 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751687AbdHRIKm (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 18 Aug 2017 04:10:42 -0400
In-Reply-To: <20170818011443.562793-1-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/18/2017 03:14 AM, Martin KaFai Lau wrote:
> In check_map_func_compatibility(), a 'break' has been accidentally
> removed for the BPF_MAP_TYPE_ARRAY_OF_MAPS and BPF_MAP_TYPE_HASH_OF_MAPS
> cases.  This patch adds it back.
>
> Fixes: 174a79ff9515 ("bpf: sockmap with sk redirect support")
> Cc: John Fastabend <john.fastabend@gmail.com>
> Signed-off-by: Martin KaFai Lau <kafai@fb.com>

Thanks for spotting!

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
