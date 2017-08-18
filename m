From: Alexei Starovoitov <ast@fb.com>
Subject: Re: [PATCH net-next] bpf: Fix map-in-map checking in the verifier
Date: Thu, 17 Aug 2017 18:17:38 -0700
Message-ID: <eb62aeba-487b-e3fe-3c9d-85c0b8eeaf04@fb.com>
References: <20170818011443.562793-1-kafai@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <daniel@iogearbox.net>, <kernel-team@fb.com>,
        John Fastabend <john.fastabend@gmail.com>
To: Martin KaFai Lau <kafai@fb.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:33543 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-FAIL)
        by vger.kernel.org with ESMTP id S1753342AbdHRBSG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 17 Aug 2017 21:18:06 -0400
In-Reply-To: <20170818011443.562793-1-kafai@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 8/17/17 6:14 PM, Martin KaFai Lau wrote:
> In check_map_func_compatibility(), a 'break' has been accidentally
> removed for the BPF_MAP_TYPE_ARRAY_OF_MAPS and BPF_MAP_TYPE_HASH_OF_MAPS
> cases.  This patch adds it back.
>
> Fixes: 174a79ff9515 ("bpf: sockmap with sk redirect support")
> Cc: John Fastabend <john.fastabend@gmail.com>
> Signed-off-by: Martin KaFai Lau <kafai@fb.com>

Nice catch!
Acked-by: Alexei Starovoitov <ast@kernel.org>
