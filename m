From: Rick Jones <rick.jones2@hpe.com>
Subject: Re: [PATCH net-next] virtio: Fix affinity for >32 VCPUs
Date: Fri, 3 Feb 2017 10:34:48 -0800
Message-ID: <7651ccc0-9ef7-0419-93ae-47da1158c2d1@hpe.com>
References: <20170203061905.100283-1-serebrin@google.com>
 <20170203170512-mutt-send-email-mst@kernel.org>
 <CAN+hb0VJKD7DwNTujL7k1E5_OQdaZbo5AugqW=_0c4MZoJ6=nA@mail.gmail.com>
 <CAF=yD-LWPoHuvbYRewALX65Y5zbSLDZb+ei2i53M=sSUDYZAuw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "Michael S. Tsirkin" <mst@redhat.com>,
        Network Development <netdev@vger.kernel.org>,
        jasowang@redhat.com, David Miller <davem@davemloft.net>,
        Willem de Bruijn <willemb@google.com>,
        Venkatesh Srinivas <venkateshs@google.com>,
        James Mattson <jmattson@google.com>
To: Willem de Bruijn <willemdebruijn.kernel@gmail.com>,
        Benjamin Serebrin <serebrin@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g2t1383g.austin.hpe.com ([15.233.16.89]:31888 "EHLO
        g2t1383g.austin.hpe.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751408AbdBCSfG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 3 Feb 2017 13:35:06 -0500
Received: from g4t3425.houston.hpe.com (g4t3425.houston.hpe.com [15.241.140.78])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by g2t1383g.austin.hpe.com (Postfix) with ESMTPS id 28E9B2781
        for <netdev@vger.kernel.org>; Fri,  3 Feb 2017 18:35:06 +0000 (UTC)
In-Reply-To: <CAF=yD-LWPoHuvbYRewALX65Y5zbSLDZb+ei2i53M=sSUDYZAuw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 02/03/2017 10:31 AM, Willem de Bruijn wrote:
> Configuring interrupts and xps from userspace at boot is more robust,
> as device driver defaults can change. But especially for customers who
> are unaware of these settings, choosing sane defaults won't hurt.

The devil is in finding the sane defaults.  For example, the issues 
we've seen with VMs sending traffic getting reordered when the driver 
took it upon itself to enable xps.

rick jones
