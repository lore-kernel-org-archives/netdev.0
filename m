From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: [PATCH net-next 2/2] tools: psock_tpacket: verify that packet
 was received on lo before counting it
Date: Wed, 4 Jan 2017 10:13:46 -0500
Message-ID: <20170104151346.GE9641@oracle.com>
References: <cover.1483482971.git.sowmini.varadhan@oracle.com>
 <3451a2008d953f33d6576a35eaefecad883eaeb5.1483482971.git.sowmini.varadhan@oracle.com>
 <CAF=yD-+d-cgE1dxCcrfNZfgVk4_wjYMHHoQ=BN7bnJ-txbM-+Q@mail.gmail.com>
 <20170104144424.GD9641@oracle.com>
 <CAF=yD-KUw8M+RGnN2eXLVgv836F6mxd4+b0h=2CP6X7mv+ScWg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kselftest@vger.kernel.org,
        Network Development <netdev@vger.kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Willem de Bruijn <willemb@google.com>,
        David Miller <davem@davemloft.net>, shuah@kernel.org
To: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:30291 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S967039AbdADPOG (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 4 Jan 2017 10:14:06 -0500
Content-Disposition: inline
In-Reply-To: <CAF=yD-KUw8M+RGnN2eXLVgv836F6mxd4+b0h=2CP6X7mv+ScWg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On (01/04/17 10:03), Willem de Bruijn wrote:
> 
> This approach is less restrictive. It still allows incorrect packets
> to be enqueued in the time between the socket call and attaching the
> bpf filter. Also, if packets are restricted to a single packet, using
> bind with sll_ifindex is simpler.

Do you want me to change this to first set up pfsocket() with
proto 0, then set up filter, and then bind_ring() to the desired
ifindex with ETH_P_ALL?

I can spin out v2 (and if I have to that, I can also fix the
comments) if you feel strongly about it.

--Sowmini
