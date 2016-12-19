From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: Re: [PATCH net] virtio_net: reject XDP programs using header adjustment
Date: Mon, 19 Dec 2016 15:42:24 +0000
Message-ID: <CAJpBn1yCHOLRYs2p4-YBYG5q3omynWkB7=5ZvoND_ULhHNv0Qw@mail.gmail.com>
References: <20161219150500.2600-1-jakub.kicinski@netronome.com> <BL2PR07MB2306FB78FBB5F2D17681699D8D910@BL2PR07MB2306.namprd07.prod.outlook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "john.fastabend@gmail.com" <john.fastabend@gmail.com>,
        "kafai@fb.com" <kafai@fb.com>,
        "daniel@iogearbox.net" <daniel@iogearbox.net>,
        "alexei.starovoitov@gmail.com" <alexei.starovoitov@gmail.com>,
        "mst@redhat.com" <mst@redhat.com>
To: "Mintz, Yuval" <Yuval.Mintz@cavium.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f173.google.com ([209.85.216.173]:35582 "EHLO
        mail-qt0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754883AbcLSPmZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 19 Dec 2016 10:42:25 -0500
Received: by mail-qt0-f173.google.com with SMTP id c47so150289775qtc.2
        for <netdev@vger.kernel.org>; Mon, 19 Dec 2016 07:42:25 -0800 (PST)
In-Reply-To: <BL2PR07MB2306FB78FBB5F2D17681699D8D910@BL2PR07MB2306.namprd07.prod.outlook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Dec 19, 2016 at 3:23 PM, Mintz, Yuval <Yuval.Mintz@cavium.com> wrote:
>> commit 17bedab27231 ("bpf: xdp: Allow head adjustment in XDP prog")
>> added a new XDP helper to prepend and remove data from a frame.
>> Make virtio_net reject programs making use of this helper until proper
>> support is added.
>>
>> Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
>
> Is that how it goes until we'll add the proper infrastructure?
> Am I expected to provide the same for qede?

I asked Martin to fix the existing drivers like qede but virtio's XDP
was not merged at that point.

> I was under the impression that so long as this is being [early] developed
> and there's no way to communicate what is and isn't supported by
> a given implementation, it would simply be the user's responsibility
> to make sure what he's trying is supported.

IMHO the less user has to guess the better if we're hoping for wide adoption.
