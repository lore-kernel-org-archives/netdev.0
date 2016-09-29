From: Rick Jones <rick.jones2@hpe.com>
Subject: Re: [PATCH v2 net-next 4/5] xps_flows: XPS for packets that don't
 have a socket
Date: Thu, 29 Sep 2016 09:35:25 -0700
Message-ID: <582e5e4e-ec5e-aafc-218d-7e7411ecc45b@hpe.com>
References: <20160929035428.204355-1-tom@herbertland.com>
 <20160929035428.204355-5-tom@herbertland.com>
 <1475124851.28155.135.camel@edumazet-glaptop3.roam.corp.google.com>
 <CALx6S36FsjSioksB+O7Lp7-7PcC8iMc9LWqWiFr8RzFJ=GkKGQ@mail.gmail.com>
 <1475155080.28155.159.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        Kernel Team <kernel-team@fb.com>,
        Alexander Duyck <alexander.duyck@gmail.com>
To: Eric Dumazet <eric.dumazet@gmail.com>,
        Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t3427.houston.hpe.com ([15.241.140.73]:30941 "EHLO
        g4t3427.houston.hpe.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933851AbcI2Qf2 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 29 Sep 2016 12:35:28 -0400
In-Reply-To: <1475155080.28155.159.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/29/2016 06:18 AM, Eric Dumazet wrote:
> Well, then what this patch series is solving ?
>
> You have a producer of packets running on 8 vcpus in a VM.
>
> Packets are exiting the VM and need to be queued on a mq NIC in the
> hypervisor.
>
> Flow X can be scheduled on any of these 8 vcpus, so XPS is currently
> selecting different TXQ.

Just for completeness, in my testing, the VMs were single-vCPU.

rick jones
