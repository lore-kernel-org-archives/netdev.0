From: Alexei Starovoitov <ast@fb.com>
Subject: Re: [PATCH 0/2] Fix some bpf program testing framework bugs
Date: Tue, 2 May 2017 08:44:41 -0700
Message-ID: <c2182110-f65a-9347-7df9-980f0018229e@fb.com>
References: <20170502.113616.583190751944798030.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <daniel@iogearbox.net>, <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-00082601.pphosted.com ([67.231.145.42]:55681 "EHLO
        mx0a-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750725AbdEBPpJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 2 May 2017 11:45:09 -0400
In-Reply-To: <20170502.113616.583190751944798030.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 5/2/17 8:36 AM, David Miller wrote:
>
> This series fixes two issue:
>
> 1) Accidental user pointer dereference in bpf_test_finish()
>
> 2) The packet data given to the test programs is not aligned correctly
>
> The first issue is fixed simply because we have a kernel side copy
> of the datastructure in question already.  And the second bug is
> a simple matter of applying NET_IP_ALIGN where needed.
>
> Signed-off-by: David S. Miller <davem@davemloft.net>

thanks a lot for the fixes.

Acked-by: Alexei Starovoitov <ast@kernel.org>
