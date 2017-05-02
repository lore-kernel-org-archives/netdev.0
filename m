From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH 1/2] bpf: Do not dereference user pointer in bpf_test_finish().
Date: Tue, 02 May 2017 17:41:09 +0200
Message-ID: <5908A895.5050703@iogearbox.net>
References: <20170502.113633.800987081837435647.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>, ast@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:36322 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751036AbdEBPlR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 2 May 2017 11:41:17 -0400
In-Reply-To: <20170502.113633.800987081837435647.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/02/2017 05:36 PM, David Miller wrote:
>
> Instead, pass the kattr in which has a kernel side copy of this
> data structure from userspace already.
>
> Fix based upon a suggestion from Alexei Starovoitov.
>
> Signed-off-by: David S. Miller <davem@davemloft.net>

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
