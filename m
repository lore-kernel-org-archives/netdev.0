From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH net] bpf: clear sender_cpu before xmit
Date: Wed, 7 Oct 2015 08:44:11 -0700
Message-ID: <56153DCB.5020003@plumgrid.com>
References: <1444189567-3031-1-git-send-email-ast@plumgrid.com>
 <5614D51E.2040109@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>, netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:34982 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754214AbbJGPoK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Oct 2015 11:44:10 -0400
Received: by pacfv12 with SMTP id fv12so25301275pac.2
        for <netdev@vger.kernel.org>; Wed, 07 Oct 2015 08:44:10 -0700 (PDT)
In-Reply-To: <5614D51E.2040109@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/7/15 1:17 AM, Daniel Borkmann wrote:
> On 10/07/2015 05:46 AM, Alexei Starovoitov wrote:
>> Similar to commit c29390c6dfee ("xps: must clear sender_cpu before
>> forwarding")
>> the skb->sender_cpu needs to be cleared before xmit.
>>
>> Fixes: 3896d655f4d4 ("bpf: introduce bpf_clone_redirect() helper")
>> Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
>
> Acked-by: Daniel Borkmann <daniel@iogearbox.net>
>
> There's one more, but for net-next, see my other email.

Of course. I left it for the morning, but you beat me to it.
