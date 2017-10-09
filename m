From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [net-next V5 PATCH 1/5] bpf: introduce new bpf cpu map type BPF_MAP_TYPE_CPUMAP
Date: Mon, 09 Oct 2017 15:40:03 +0200
Message-ID: <59DB7C33.9090702@iogearbox.net>
References: <150730632837.22839.11804085686478888137.stgit@firesoul> <150730636196.22839.17119032803741721925.stgit@firesoul> <59DB7A29.5050906@iogearbox.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: jakub.kicinski@netronome.com,
        "Michael S. Tsirkin" <mst@redhat.com>, pavel.odintsov@gmail.com,
        Jason Wang <jasowang@redhat.com>, mchan@broadcom.com,
        John Fastabend <john.fastabend@gmail.com>,
        peter.waskiewicz.jr@intel.com,
        Daniel Borkmann <borkmann@iogearbox.net>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Andy Gospodarek <andy@greyhouse.net>
To: Jesper Dangaard Brouer <brouer@redhat.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:52420 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751635AbdJINkG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 9 Oct 2017 09:40:06 -0400
In-Reply-To: <59DB7A29.5050906@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/09/2017 03:31 PM, Daniel Borkmann wrote:
> On 10/06/2017 06:12 PM, Jesper Dangaard Brouer wrote:
[...]
>> +    /* Pre-limit array size based on NR_CPUS, not final CPU check */
>> +    if (cmap->map.max_entries > NR_CPUS)
>
> Nit: needs to be >= NR_CPUS.

Scratch that comment, you bail out on key_cpu >= cmap->map.max_entries
in the other handlers, so that's fine.
