From: David Ahern <dsahern@gmail.com>
Subject: Re: v6/sit tunnels and VRFs
Date: Wed, 25 Oct 2017 15:31:35 -0600
Message-ID: <fc420b5d-f179-a1fb-9cf5-ce1820870c83@gmail.com>
References: <CAL6e_pdXJFoVVCfAOc9D_kE73juGQzjoUueEBvEMS=cq5CDKkg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
To: Jeff Barnhill <0xeffeff@gmail.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f173.google.com ([209.85.192.173]:51354 "EHLO
        mail-pf0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751668AbdJYVbr (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 25 Oct 2017 17:31:47 -0400
Received: by mail-pf0-f173.google.com with SMTP id n14so902560pfh.8
        for <netdev@vger.kernel.org>; Wed, 25 Oct 2017 14:31:46 -0700 (PDT)
In-Reply-To: <CAL6e_pdXJFoVVCfAOc9D_kE73juGQzjoUueEBvEMS=cq5CDKkg@mail.gmail.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/25/17 2:45 PM, Jeff Barnhill wrote:
> Are v6/sit tunnels working with VRFs?
> 
> For instance, I have a very simple configuration with three VMs
> running 4.13.0-16 (Ubuntu Server 17.10) kernels.  VM3 is setup as a
> router for separation.  VM1 and VM2 have static routes to each other
> via VM3.  All VMs have v4 interfaces configured.  If I setup a sit
> tunnel with v6 addrs from V1 to V2, tunneled data flows as expected
> (verified with ping) and can be seen via tcpdump on VM3.  However, if
> I create a VRF on VM2 and enslave the v4 interface and tunnel to that
> VRF, data does not leave VM2 and ping displays "Destination Host
> Unreachable".  I did verify that basic v4 ping works between VM1 and
> VM2 with the v4 interface on VM2 enslaved to VRF device.
> 
> If this should work, I can provide more details with configuration commands.

Please provide configuration details and I'll take a look
