From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net 1/3] bpf: fix incorrect pruning decision when alignment
 must be tracked
Date: Wed, 24 May 2017 22:17:26 +0200
Message-ID: <5925EA56.3090404@iogearbox.net>
References: <cover.1495556127.git.daniel@iogearbox.net> <cover.1495556127.git.daniel@iogearbox.net>     <170aa8062f2c54186a6567b5be8fca0cddec53be.1495556127.git.daniel@iogearbox.net> <20170524.160733.216900339299848648.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: ast@fb.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:47751 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S964823AbdEXURb (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 24 May 2017 16:17:31 -0400
In-Reply-To: <20170524.160733.216900339299848648.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/24/2017 10:07 PM, David Miller wrote:
> From: Daniel Borkmann <daniel@iogearbox.net>
> Date: Tue, 23 May 2017 18:30:41 +0200
>
>> +	if (!env->strict_alignment && old->off <= cur->off &&
>
> You can't just test env->strict_alignment by itself, that's just an
> override and doesn't determine the actual "strict" value we use which
> is a combination of env->strict_alignment and
> "!CONFIG_HAVE_EFFICIENT_UNALIGNED_ACCESS".
>
> So you'll have to update this test.

Argh, good point, true. Will respin with a v2.
