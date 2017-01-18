From: Bart Van Assche <bart.vanassche@sandisk.com>
Subject: Re: [RFC] RESEND - rdmatool - tool for RDMA users
Date: Wed, 18 Jan 2017 13:45:14 -0800
Message-ID: <5f90fd26-e7bf-bb2a-01f2-6b166f2265e9@sandisk.com>
References: <CABvr3-GZQs51Sn3XagTsepsy3CHvx6P=GVJzefajbNt9jxz9Kg@mail.gmail.com>
 <CAJ3xEMgO496ctgCUp1sW=-pCUyniy7LZb8hSkyNeYsJ1V4aVwg@mail.gmail.com>
 <20170118173327.GF32481@mtr-leonro.local>
 <CAJ3xEMiR1+NGghUZJ6aGq+=xTdOHU5Ph-BcPii5OUB8dT4Vq-A@mail.gmail.com>
 <20170118183127.GC14198@obsidianresearch.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="windows-1252"
Content-Transfer-Encoding: 7bit
Cc: Leon Romanovsky <leonro@mellanox.com>,
        Ariel Almog <arielalmogworkemails@gmail.com>,
        "linux-rdma@vger.kernel.org" <linux-rdma@vger.kernel.org>,
        Linux Netdev List <netdev@vger.kernel.org>
To: Jason Gunthorpe <jgunthorpe@obsidianresearch.com>,
        Or Gerlitz <gerlitz.or@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bn3nam01on0047.outbound.protection.outlook.com ([104.47.33.47]:43904
        "EHLO NAM01-BN3-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1753246AbdARVpb (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 18 Jan 2017 16:45:31 -0500
In-Reply-To: <20170118183127.GC14198@obsidianresearch.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/18/2017 10:31 AM, Jason Gunthorpe wrote:
> I think it depends on what this tool is supposed to cover, but based
> on the description, I would start with netlink-only.
> 
> The only place verbs covers a similar ground is in 'device
> capabilities' - for some of that you might want to open a new-uAPI
> verbs fd, but even the capability data from that would not be
> totally offensive to be accessed over netlink.
> 
> IMHO netlink should cover almost everything found in sysfs today.

We would need a very strong argument to introduce a netlink API that
duplicates existing sysfs API functionality. Since the sysfs API is
extensible, why not extend that API further? E.g. the SCST sysfs API
shows that more is possible with sysfs than what most kernel drivers
realize.

Bart.
