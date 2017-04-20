From: John Fastabend <john.fastabend@gmail.com>
Subject: Re: XDP question: best API for returning/setting egress port?
Date: Wed, 19 Apr 2017 21:43:53 -0700
Message-ID: <58F83C89.4070808@gmail.com>
References: <20170418215856.5fda7127@redhat.com>
 <20170419200259.GK4730@C02RW35GFVH8.dhcp.broadcom.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <borkmann@iogearbox.net>,
        Alexei Starovoitov <alexei.starovoitov@gmail.com>,
        Alexei Starovoitov <ast@fb.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "xdp-newbies@vger.kernel.org" <xdp-newbies@vger.kernel.org>
To: Andy Gospodarek <andy@greyhouse.net>,
        Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f178.google.com ([209.85.223.178]:32906 "EHLO
        mail-io0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S941072AbdDTEoP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 20 Apr 2017 00:44:15 -0400
In-Reply-To: <20170419200259.GK4730@C02RW35GFVH8.dhcp.broadcom.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

[...]

> JohnF, any test results with this you can share?  Presumably you tested with
> virtio-net, right?
> 

For my patches using the xdp_redirect with virtio-net showed no measurable
difference from running just the straight XDP_TX in the PPS column. However
virtio_net XDP_TX was quite low to start with (and I was mostly just looking
at functionality so I don't recall if there was a CPU usage hit) so I expect on
ixgbe to see a difference. However I have plenty of cpu overhead to consume on
the 10Gbps card so it will likely just be a CPU % cost not a PPS cost. I'll
bother Alex about the 40Gbps cards ;)

Anyways, I'll put it on my list to rerun. But like the xdp generic pieces it
wont be for a couple days until I get around to it. Sorry need to take care of
a few things first.

Thanks,
John
