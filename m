From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: prog ID and next steps. Was: [RFC net-next 0/2] Introduce
 bpf_prog ID and iteration
Date: Fri, 28 Apr 2017 20:57:08 +0200
Message-ID: <5b211e10-3890-cd52-a4cd-92ce00a34cda@stressinduktion.org>
References: <20170427062449.80290-1-kafai@fb.com>
 <e81805c8-0499-a0a5-b788-0168947d9b8c@stressinduktion.org>
 <40cf6893-4702-4773-1aaa-7dfdc51c6212@fb.com>
 <44cdb2d2-9f5c-5d28-2966-3e43e6d2a2ef@stressinduktion.org>
 <590388C2.7080000@iogearbox.net>
 <e4931eaa-c126-bd7f-4865-84a251624583@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: kernel-team@fb.com, "David S. Miller" <davem@davemloft.net>,
        Jesper Dangaard Brouer <brouer@redhat.com>,
        John Fastabend <john.fastabend@gmail.com>,
        Thomas Graf <tgraf@suug.ch>
To: Daniel Borkmann <daniel@iogearbox.net>,
        Alexei Starovoitov <ast@fb.com>,
        Martin KaFai Lau <kafai@fb.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4-smtp.messagingengine.com ([66.111.4.28]:56467 "EHLO
        out4-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1425368AbdD1S5M (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 28 Apr 2017 14:57:12 -0400
In-Reply-To: <e4931eaa-c126-bd7f-4865-84a251624583@stressinduktion.org>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 28.04.2017 20:51, Hannes Frederic Sowa wrote:
> Doesn't this break if I have 2 mlx4 cards in the system with different
> XDP programs attached? I would have to add an additional parameter to
> one of the mlx4 functions to extract the net_device pointer to make the
> correlation then. Probably it will be much more difficult for other hooks.

Addendum:

I am referring to same XDP programs attached to two mlx4 NICs which use
different maps. It will be possible to correlate that with some more
advanced perf magic, if the driver passes suitable pointers around so
you can dereference the device name. Also, I am not sure where the
support for multi-rx-queue XDP is heading. It might be even more
difficult to understand it then.

Bye,
Hannes
