From: Cong Wang <xiyou.wangcong@gmail.com>
Subject: Re: [Patch net-next] net: remove skb_sender_cpu_clear()
Date: Mon, 29 Feb 2016 10:55:11 -0800
Message-ID: <CAM_iQpUtGbSnvV3Zi74Q5DsZBAAFGZyvjkkeBRciHxwTm4GCEg@mail.gmail.com>
References: <1456633194-2510-1-git-send-email-xiyou.wangcong@gmail.com>
	<56D492E7.4060900@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>
To: Daniel Borkmann <daniel@iogearbox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f170.google.com ([209.85.161.170]:32926 "EHLO
	mail-yw0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751330AbcB2SzM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 29 Feb 2016 13:55:12 -0500
Received: by mail-yw0-f170.google.com with SMTP id u200so129109229ywf.0
        for <netdev@vger.kernel.org>; Mon, 29 Feb 2016 10:55:11 -0800 (PST)
In-Reply-To: <56D492E7.4060900@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 29, 2016 at 10:50 AM, Daniel Borkmann <daniel@iogearbox.net> wrote:
> On 02/28/2016 05:19 AM, Cong Wang wrote:
>>
>> After commit 52bd2d62ce67 ("net: better skb->sender_cpu and skb->napi_id
>> cohabitation")
>> skb_sender_cpu_clear() becomes empty and can be removed.
>>
>> Cc: Eric Dumazet <edumazet@google.com>
>> Signed-off-by: Cong Wang <xiyou.wangcong@gmail.com>
>
>
> Wasn't the intention to keep this helper as a marker when packet
> crosses domains from RX to TX, see discussion here:
>
>   https://patchwork.ozlabs.org/patch/527167/
>
> Maybe better to rename it and add a comment into the helper to
> make the intention more clear?

Since when we need an empty function to mark some call path?
Isn't this supposed to be done by comments or documents?

BTW, I myself even don't think we need any comment, people
who touches it should understand it.
