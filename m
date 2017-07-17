From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [Patch net] bpf: check NULL for sk_to_full_sk() return value
Date: Mon, 17 Jul 2017 21:06:49 +0200
Message-ID: <596D0AC9.7070505@iogearbox.net>
References: <20170717184255.6121-1-xiyou.wangcong@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: dsahern@gmail.com, Lawrence Brakmo <brakmo@fb.com>
To: Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:53734 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751311AbdGQTGz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 17 Jul 2017 15:06:55 -0400
In-Reply-To: <20170717184255.6121-1-xiyou.wangcong@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/17/2017 08:42 PM, Cong Wang wrote:
> When req->rsk_listener is NULL, sk_to_full_sk() returns
> NULL too, so we have to check its return value against
> NULL here.
>
> Fixes: 40304b2a1567 ("bpf: BPF support for sock_ops")
> Reported-by: David Ahern <dsahern@gmail.com>
> Tested-by: David Ahern <dsahern@gmail.com>
> Cc: Lawrence Brakmo <brakmo@fb.com>
> Cc: Daniel Borkmann <daniel@iogearbox.net>
> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>

Acked-by: Daniel Borkmann <daniel@iogearbox.net>
