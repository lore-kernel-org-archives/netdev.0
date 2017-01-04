From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: [PATCH net-next 2/2] tools: psock_tpacket: verify that packet
 was received on lo before counting it
Date: Wed, 4 Jan 2017 09:44:24 -0500
Message-ID: <20170104144424.GD9641@oracle.com>
References: <cover.1483482971.git.sowmini.varadhan@oracle.com>
 <3451a2008d953f33d6576a35eaefecad883eaeb5.1483482971.git.sowmini.varadhan@oracle.com>
 <CAF=yD-+d-cgE1dxCcrfNZfgVk4_wjYMHHoQ=BN7bnJ-txbM-+Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kselftest@vger.kernel.org,
        Network Development <netdev@vger.kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Willem de Bruijn <willemb@google.com>,
        David Miller <davem@davemloft.net>, shuah@kernel.org
To: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:32089 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1031173AbdADOo4 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 4 Jan 2017 09:44:56 -0500
Content-Disposition: inline
In-Reply-To: <CAF=yD-+d-cgE1dxCcrfNZfgVk4_wjYMHHoQ=BN7bnJ-txbM-+Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On (01/04/17 09:30), Willem de Bruijn wrote:
> 
> The common and simpler solution to this problem is to open the socket
> with protocol 0 to reject all packets, add the BPF filter and only then bind
> with sll_ifindex set to lo. That way no false positives can arrive.

Yes, I thought of that too (and I've seen that done in one commercial
implementation), but given that tpacket nicely returns the incoming
interface, I figured, why not use the test prog to use this (thus
verifying it, and also showing how to use it)

--Sowmini
