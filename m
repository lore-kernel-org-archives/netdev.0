From: Tom Herbert <tom@herbertland.com>
Subject: Re: [PATCH v7 00/11] Add driver bpf hook for early packet drop and forwarding
Date: Mon, 11 Jul 2016 16:26:36 -0700
Message-ID: <CALx6S36=Cqtte2Eer0VF-_4ki7Z-xk_2jgw4xXCvRGLb7gGbxg@mail.gmail.com>
References: <1468272598-21390-1-git-send-email-bblanco@plumgrid.com> <CAJ3xEMgVtqETM8XHt5gedAmKoBGwggnKDr3iWUeRYFtvQRfQEw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Brenden Blanco <bblanco@plumgrid.com>,
	David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Jamal Hadi Salim <jhs@mojatatu.com>,
	Saeed Mahameed <saeedm@dev.mellanox.co.il>,
	Martin KaFai Lau <kafai@fb.com>,
	Jesper Dangaard Brouer <brouer@redhat.com>,
	Ari Saha <as754m@att.com>,
	Alexei Starovoitov <alexei.starovoitov@gmail.com>,
	john fastabend <john.fastabend@gmail.com>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>,
	Thomas Graf <tgraf@suug.ch>,
	Daniel Borkmann <daniel@iogearbox.net>
To: Or Gerlitz <gerlitz.or@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f51.google.com ([209.85.214.51]:32814 "EHLO
	mail-it0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751580AbcGKX0i (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Jul 2016 19:26:38 -0400
Received: by mail-it0-f51.google.com with SMTP id f6so483231ith.0
        for <netdev@vger.kernel.org>; Mon, 11 Jul 2016 16:26:37 -0700 (PDT)
In-Reply-To: <CAJ3xEMgVtqETM8XHt5gedAmKoBGwggnKDr3iWUeRYFtvQRfQEw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jul 11, 2016 at 2:53 PM, Or Gerlitz <gerlitz.or@gmail.com> wrote:
> On Tue, Jul 12, 2016 at 12:29 AM, Brenden Blanco <bblanco@plumgrid.com> wrote:
>
>> v7:
> [...]
>>  TODOs:
>>  Add ethtool per-ring stats for aborted, default cases, maybe even drop
>>  and tx as well.
>
> please no... lets stop and think if we can have something better vs
> every XDP enabled driver to have bunch of new ethtool based stats, was
> this somehow discussed over the threads so far?

We'll also need to consider statistics what statistics a device keeps
and how they are exposed when the device offloads XDP, and also the
possibility that the BPF program itself might keep its own stats.

Tom
