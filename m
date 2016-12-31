From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: [PATCH net-next] af_packet: Provide a TPACKET_V2 compatible Tx
 path for TPACKET_V3
Date: Sat, 31 Dec 2016 07:21:38 -0500
Message-ID: <20161231122138.GA5627@oracle.com>
References: <1483116853-45769-1-git-send-email-sowmini.varadhan@oracle.com>
 <CAF=yD-+CMjr_9s2wVZOQEPAP5h9jpnMe3vckYGbQ9hnQoGWFEw@mail.gmail.com>
 <20161230230316.GB31800@oracle.com>
 <CAF=yD-JiRDnYPB=W37T5tF7rVVGD5bACK6YkSWwuGdF2PdOdBQ@mail.gmail.com>
 <20161231004826.GC31800@oracle.com>
 <CAF=yD-Jgui0gBeZuzfJRN1uozV+LqVm76tnKUnChSg7_z9-1ng@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Network Development <netdev@vger.kernel.org>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Willem de Bruijn <willemb@google.com>,
        David Miller <davem@davemloft.net>
To: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from aserp1040.oracle.com ([141.146.126.69]:18394 "EHLO
        aserp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752703AbcLaMWH (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 31 Dec 2016 07:22:07 -0500
Content-Disposition: inline
In-Reply-To: <CAF=yD-Jgui0gBeZuzfJRN1uozV+LqVm76tnKUnChSg7_z9-1ng@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On (12/30/16 23:59), Willem de Bruijn wrote:
> > Actually I'm not averse to looking at extensions (or at least,
> > place-holders) to allow variable sized slots- do you have any
> > suggestions?
> 
> It is probably enough to just enforce that tp_next_offset is always
> sane. Either that it points to the start of the next packet, even
> though that currently can also be inferred from frame_size. Or, that
> it is always zero unless the ring is to be interpreted as holding
> variable sized frames. If the field is non-zero, drop the packet.

Ok, let me add this to patchv2, along with extra test cases.

--Sowmini
