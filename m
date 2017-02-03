From: Rick Jones <rick.jones2@hpe.com>
Subject: Re: [PATCH net-next] virtio: Fix affinity for >32 VCPUs
Date: Fri, 3 Feb 2017 10:33:06 -0800
Message-ID: <088e4130-3444-251b-c6f3-9c4d9bb3e255@hpe.com>
References: <20170203061905.100283-1-serebrin@google.com>
 <20170203170512-mutt-send-email-mst@kernel.org>
 <CAN+hb0VJKD7DwNTujL7k1E5_OQdaZbo5AugqW=_0c4MZoJ6=nA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jasowang@redhat.com,
        David Miller <davem@davemloft.net>,
        Willem de Bruijn <willemb@google.com>,
        Venkatesh Srinivas <venkateshs@google.com>,
        James Mattson <jmattson@google.com>
To: Benjamin Serebrin <serebrin@google.com>,
        "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g2t1383g.austin.hpe.com ([15.233.16.89]:31879 "EHLO
        g2t1383g.austin.hpe.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750995AbdBCSeC (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 3 Feb 2017 13:34:02 -0500
Received: from g4t3425.houston.hpe.com (g4t3425.houston.hpe.com [15.241.140.78])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by g2t1383g.austin.hpe.com (Postfix) with ESMTPS id 08DF126F
        for <netdev@vger.kernel.org>; Fri,  3 Feb 2017 18:34:01 +0000 (UTC)
In-Reply-To: <CAN+hb0VJKD7DwNTujL7k1E5_OQdaZbo5AugqW=_0c4MZoJ6=nA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/03/2017 10:22 AM, Benjamin Serebrin wrote:
> Thanks, Michael, I'll put this text in the commit log:
>
> XPS settings aren't write-able from userspace, so the only way I know
> to fix XPS is in the driver.

??

root@np-cp1-c0-m1-mgmt:/home/stack# cat 
/sys/devices/pci0000:00/0000:00:02.0/0000:04:00.0/net/hed0/queues/tx-0/xps_cpus
00000000,00000001
root@np-cp1-c0-m1-mgmt:/home/stack# echo 0 > 
/sys/devices/pci0000:00/0000:00:02.0/0000:04:00.0/net/hed0/queues/tx-0/xps_cpus
root@np-cp1-c0-m1-mgmt:/home/stack# cat 
/sys/devices/pci0000:00/0000:00:02.0/0000:04:00.0/net/hed0/queues/tx-0/xps_cpus
00000000,00000000
