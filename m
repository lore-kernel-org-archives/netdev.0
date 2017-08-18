From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: [PATCH net-next] bpf: Fix map-in-map checking in the verifier
Date: Thu, 17 Aug 2017 19:08:26 -0700
Message-ID: <59964C1A.7050902@gmail.com>
References: <20170818011443.562793-1-kafai@fb.com> <eb62aeba-487b-e3fe-3c9d-85c0b8eeaf04@fb.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <daniel@iogearbox.net>, kernel-team@fb.com
To: Alexei Starovoitov <ast@fb.com>, Martin KaFai Lau <kafai@fb.com>,
        netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f45.google.com ([74.125.83.45]:35885 "EHLO
        mail-pg0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753890AbdHRCIi (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 17 Aug 2017 22:08:38 -0400
Received: by mail-pg0-f45.google.com with SMTP id i12so54349537pgr.3
        for <netdev@vger.kernel.org>; Thu, 17 Aug 2017 19:08:38 -0700 (PDT)
In-Reply-To: <eb62aeba-487b-e3fe-3c9d-85c0b8eeaf04@fb.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/17/2017 06:17 PM, Alexei Starovoitov wrote:
> On 8/17/17 6:14 PM, Martin KaFai Lau wrote:
>> In check_map_func_compatibility(), a 'break' has been accidentally
>> removed for the BPF_MAP_TYPE_ARRAY_OF_MAPS and BPF_MAP_TYPE_HASH_OF_MAPS
>> cases.  This patch adds it back.
>>
>> Fixes: 174a79ff9515 ("bpf: sockmap with sk redirect support")
>> Cc: John Fastabend <john.fastabend@gmail.com>
>> Signed-off-by: Martin KaFai Lau <kafai@fb.com>
> 
> Nice catch!
> Acked-by: Alexei Starovoitov <ast@kernel.org>
> 

Thanks a lot!

Acked-by: John Fastabend <john.fastabend@gmail.com>
