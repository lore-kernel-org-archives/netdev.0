From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net] bpf: fix bpf_setsockopts return value
Date: Fri, 25 Aug 2017 01:37:07 +0200
Message-ID: <599F6323.2000107@iogearbox.net>
References: <20170824224821.31672-1-ycheng@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: ncardwell@google.com, cgallek@google.com, netdev@vger.kernel.org
To: Yuchung Cheng <ycheng@google.com>, davem@davemloft.net,
        brakmo@fb.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:49182 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753495AbdHXXhN (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 24 Aug 2017 19:37:13 -0400
In-Reply-To: <20170824224821.31672-1-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 08/25/2017 12:48 AM, Yuchung Cheng wrote:
> This patch fixes a bug causing any sock operations to always return EINVAL.
>
> Fixes: a5192c52377e ("bpf: fix to bpf_setsockops").
> Reported-by: Neal Cardwell <ncardwell@google.com>
> Signed-off-by: Yuchung Cheng <ycheng@google.com>
> Acked-by: Neal Cardwell <ncardwell@google.com>
> Acked-by: Craig Gallek <kraig@google.com>

Ohh well, thanks for the fix!

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
