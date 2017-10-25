From: Jeff Barnhill <0xeffeff@gmail.com>
Subject: v6/sit tunnels and VRFs
Date: Wed, 25 Oct 2017 16:45:18 -0400
Message-ID: <CAL6e_pdXJFoVVCfAOc9D_kE73juGQzjoUueEBvEMS=cq5CDKkg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f180.google.com ([209.85.217.180]:44346 "EHLO
        mail-ua0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751775AbdJYUpT (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 25 Oct 2017 16:45:19 -0400
Received: by mail-ua0-f180.google.com with SMTP id f46so992790uae.1
        for <netdev@vger.kernel.org>; Wed, 25 Oct 2017 13:45:19 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Are v6/sit tunnels working with VRFs?

For instance, I have a very simple configuration with three VMs
running 4.13.0-16 (Ubuntu Server 17.10) kernels.  VM3 is setup as a
router for separation.  VM1 and VM2 have static routes to each other
via VM3.  All VMs have v4 interfaces configured.  If I setup a sit
tunnel with v6 addrs from V1 to V2, tunneled data flows as expected
(verified with ping) and can be seen via tcpdump on VM3.  However, if
I create a VRF on VM2 and enslave the v4 interface and tunnel to that
VRF, data does not leave VM2 and ping displays "Destination Host
Unreachable".  I did verify that basic v4 ping works between VM1 and
VM2 with the v4 interface on VM2 enslaved to VRF device.

If this should work, I can provide more details with configuration commands.

Thanks,
Jeff
