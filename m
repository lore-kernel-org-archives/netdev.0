From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH v2 6/7] bpf: Make use of alignment information in check_val_ptr_alignment().
Date: Thu, 11 May 2017 19:53:31 +0200
Message-ID: <5914A51B.1090007@iogearbox.net>
References: <20170511.120608.248672395765712270.davem@davemloft.net>        <59149629.4090109@iogearbox.net> <20170511.132354.1049312079662884972.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: ast@fb.com, alexei.starovoitov@gmail.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:36362 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932708AbdEKRxh (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 11 May 2017 13:53:37 -0400
In-Reply-To: <20170511.132354.1049312079662884972.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 05/11/2017 07:23 PM, David Miller wrote:
> From: Daniel Borkmann <daniel@iogearbox.net>
> Date: Thu, 11 May 2017 18:49:45 +0200
>
>> This actually won't work, see also commit 79adffcd6489 ("bpf,
>> verifier:
>> fix rejection of unaligned access checks for map_value_adj") with some
>> longer explanation. In case of map_value_adj, reg->id is always 0.
>
> I see....
>
> Ok if I merge in the first 5 patches then?

Yes, please. :)

> I'll look more deeply into the MAP value issues.

Ok, thanks for looking into it!
