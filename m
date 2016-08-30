From: Jamal Hadi Salim <jhs@mojatatu.com>
Subject: Re: [net-next PATCH] e1000: add initial XDP support
Date: Tue, 30 Aug 2016 08:13:15 -0400
Message-ID: <09886285-aeae-625d-9d0e-bec1c1944efe@mojatatu.com>
References: <20160827071145.25345.84712.stgit@john-Precision-Tower-5810>
 <b6cfb3c5-9c68-3ea7-48dd-7fbf666db751@mojatatu.com>
 <20160829103047.3968a4d8@redhat.com>
 <61de1b91-30b4-67ba-4192-834fa30757ea@mojatatu.com>
 <20160829153905.50066865@redhat.com> <20160829175509.7ed19b89@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: John Fastabend <john.fastabend@gmail.com>, bblanco@plumgrid.com,
        davem@davemloft.net, alexei.starovoitov@gmail.com,
        john.r.fastabend@intel.com, netdev@vger.kernel.org,
        xiyou.wangcong@gmail.com
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f66.google.com ([209.85.214.66]:34888 "EHLO
        mail-it0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755916AbcH3MNS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 30 Aug 2016 08:13:18 -0400
Received: by mail-it0-f66.google.com with SMTP id f128so1833239ith.2
        for <netdev@vger.kernel.org>; Tue, 30 Aug 2016 05:13:17 -0700 (PDT)
In-Reply-To: <20160829175509.7ed19b89@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 16-08-29 11:55 AM, Jesper Dangaard Brouer wrote:
> tc filter add dev mlx5p2 parent ffff: prio 4 protocol ip u32 match ip protocol 17 0xff match udp dst 9 0xffff flowid 1:1 action

Syntax is a little more convoluted  than that ;->. Try:

sudo tc filter add dev eth0 parent ffff: prio 4 protocol ip u32 \
match ip protocol 17 0xff \
match ip dport 1900 0xffff \
flowid 1:1 \
action drop

Note, this will be more cycles than drop all.

cheers,
jamal
