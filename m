From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [net-next PATCH] bpf: devmap: remove unnecessary value size check
Date: Wed, 16 Aug 2017 10:39:58 +0200
Message-ID: <599404DE.8030400@iogearbox.net>
References: <20170816063512.14925.40390.stgit@john-Precision-Tower-5810>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: John Fastabend <john.fastabend@gmail.com>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:33718 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751454AbdHPIkC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 16 Aug 2017 04:40:02 -0400
In-Reply-To: <20170816063512.14925.40390.stgit@john-Precision-Tower-5810>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/16/2017 08:35 AM, John Fastabend wrote:
> In the devmap alloc map logic we check to ensure that the sizeof the
> values are not greater than KMALLOC_MAX_SIZE. But, in the dev map case
> we ensure the value size is 4bytes earlier in the function because all
> values should be netdev ifindex values.
>
> The second check is harmless but is not needed so remove it.
>
> Signed-off-by: John Fastabend <john.fastabend@gmail.com>

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
