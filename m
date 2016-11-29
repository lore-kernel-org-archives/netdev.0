From: David Ahern <dsa@cumulusnetworks.com>
Subject: Re: [PATCH net-next] samples/bpf: fix include path
Date: Tue, 29 Nov 2016 08:55:50 -0700
Message-ID: <c1ccee76-949a-fa1c-9775-49bcdaea7a26@cumulusnetworks.com>
References: <1480399642-2475887-1-git-send-email-ast@fb.com>
 <583D2187.7060405@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>,
        Alexei Starovoitov <ast@fb.com>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f169.google.com ([209.85.192.169]:35521 "EHLO
        mail-pf0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757258AbcK2Pzx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2016 10:55:53 -0500
Received: by mail-pf0-f169.google.com with SMTP id i88so32576173pfk.2
        for <netdev@vger.kernel.org>; Tue, 29 Nov 2016 07:55:53 -0800 (PST)
In-Reply-To: <583D2187.7060405@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 11/28/16 11:34 PM, Daniel Borkmann wrote:
> On 11/29/2016 07:07 AM, Alexei Starovoitov wrote:
>> Fix the following build error:
>> HOSTCC  samples/bpf/test_lru_dist.o
>> ../samples/bpf/test_lru_dist.c:25:22: fatal error: bpf_util.h: No such file or directory
>>
>> This is due to objtree != srctree.
>> Use srctree, since that's where bpf_util.h is located.
>>
>> Fixes: e00c7b216f34 ("bpf: fix multiple issues in selftest suite and samples")
>> Signed-off-by: Alexei Starovoitov <ast@kernel.org>
> 
> Didn't run into this so far, thanks for fixing!
> 
> Acked-by: Daniel Borkmann <daniel@iogearbox.net>

I have and this fixed it for me.

Tested-by: David Ahern <dsa@cumulusnetworks.com>
