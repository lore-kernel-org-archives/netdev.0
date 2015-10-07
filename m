From: Alexei Starovoitov <ast@plumgrid.com>
Subject: Re: [PATCH net-next] bpf, skb_do_redirect: clear sender_cpu before
 xmit
Date: Wed, 7 Oct 2015 08:46:52 -0700
Message-ID: <56153E6C.9050202@plumgrid.com>
References: <ceae3b812d3e01f73efcfdff0a7817b3c61ae24e.1444205375.git.daniel@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: edumazet@google.com, netdev@vger.kernel.org
To: Daniel Borkmann <daniel@iogearbox.net>, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:36634 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753651AbbJGPqw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 7 Oct 2015 11:46:52 -0400
Received: by pablk4 with SMTP id lk4so24882994pab.3
        for <netdev@vger.kernel.org>; Wed, 07 Oct 2015 08:46:52 -0700 (PDT)
In-Reply-To: <ceae3b812d3e01f73efcfdff0a7817b3c61ae24e.1444205375.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/7/15 1:16 AM, Daniel Borkmann wrote:
> Similar to commit c29390c6dfee ("xps: must clear sender_cpu before
> forwarding"), we also need to clear the skb->sender_cpu when moving
> from RX to TX via skb_do_redirect() due to the shared location of
> napi_id (used on RX) and sender_cpu (used on TX).
>
> Fixes: 27b29f63058d ("bpf: add bpf_redirect() helper")
> Signed-off-by: Daniel Borkmann<daniel@iogearbox.net>

Acked-by: Alexei Starovoitov <ast@plumgrid.com>

with the amount of skb_sender_cpu_clear() all over the code base
I wonder whether there is a better solution to all of these.
