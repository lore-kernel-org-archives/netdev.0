From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: What is the correct behavior ipv4/ipv6
Date: Mon, 17 Jul 2017 22:08:14 -0700
Message-ID: <1500354494.5566.36.camel@edumazet-glaptop3.roam.corp.google.com>
References: <f7aa79a4-81d9-5b6d-3a27-0d681e5619ae@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Rao Shoaib <rao.shoaib@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wr0-f173.google.com ([209.85.128.173]:35467 "EHLO
        mail-wr0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751026AbdGRFIR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 18 Jul 2017 01:08:17 -0400
Received: by mail-wr0-f173.google.com with SMTP id w4so11483528wrb.2
        for <netdev@vger.kernel.org>; Mon, 17 Jul 2017 22:08:16 -0700 (PDT)
In-Reply-To: <f7aa79a4-81d9-5b6d-3a27-0d681e5619ae@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2017-07-17 at 11:28 -0700, Rao Shoaib wrote:
> I am looking at a system which is configured for IPv6 only but sits in a 
> network that serves both IPv4 and IPv6. When an IPv4 packet with a 
> destination  broadcast address is sent out (in this case DHCP) the 
> system accepts it and since it does not have any route to the sender it 
> prints the Martian message.

Which message exactly is printed ?

> 
> Sure, we can turn off the Martian message and maybe the system should be 
> in an IPv6 only network.
> 
> The question that is being asked is that why is the system accepting an 
> IPv4 broadcast packet in the first place ?  Is this behavior incorrect 
> and should I submit a patch ?
> 
> Thanks,
> 
> Shoaib
> 
