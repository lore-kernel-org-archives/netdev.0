From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [net-next V3 PATCH 3/5] bpf: cpumap xdp_buff to skb conversion
 and allocation
Date: Tue, 03 Oct 2017 16:25:25 +0200
Message-ID: <59D39DD5.1010903@iogearbox.net>
References: <150696027949.24152.7507025809123255386.stgit@firesoul>        <150696032966.24152.3096148163967111058.stgit@firesoul>        <20171003010245.f3op4t56crbjc4ke@ast-mbp> <20171003085843.14d3491e@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jakub.kicinski@netronome.com,
        "Michael S. Tsirkin" <mst@redhat.com>, pavel.odintsov@gmail.com,
        Jason Wang <jasowang@redhat.com>, mchan@broadcom.com,
        John Fastabend <john.fastabend@gmail.com>,
        peter.waskiewicz.jr@intel.com,
        Daniel Borkmann <borkmann@iogearbox.net>,
        Andy Gospodarek <andy@greyhouse.net>
To: Jesper Dangaard Brouer <brouer@redhat.com>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:46752 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751291AbdJCOZ2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 3 Oct 2017 10:25:28 -0400
In-Reply-To: <20171003085843.14d3491e@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/03/2017 08:58 AM, Jesper Dangaard Brouer wrote:
[...]
>> Or you're calling netif_receive_skb() to be able to call
>> generic XDP on that cpu again ?
>
> That should not (currently) be possible. AFAIK we (Daniel) choose to
> not allow Native and Generic XDP to be loaded on the same net_device.
> (With the same ABI argument as here)

Correct, it's either native or generic, but not both.
