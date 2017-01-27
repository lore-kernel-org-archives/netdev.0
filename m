From: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Subject: Re: [PATCH RFC net-next] packet: always ensure that we pass
 hard_header_len bytes in skb_headlen() to the driver
Date: Fri, 27 Jan 2017 12:03:20 -0500
Message-ID: <20170127170320.GD25829@oracle.com>
References: <1485274309-201670-1-git-send-email-sowmini.varadhan@oracle.com>
 <CAF=yD-KXqpODBVQ0vUt1a1p_mMXzzQp=5GU33f9GY9_cbPJxDw@mail.gmail.com>
 <20170126213742.GE29475@oracle.com>
 <CAF=yD-L66dFV64fx21A3059LRiot_-j0Ykp9GkRFwf52099upQ@mail.gmail.com>
 <20170127020836.GH29475@oracle.com>
 <CAF=yD-LWLDQhQMBA9O5T5k+di5VKMPtix+pHLb-zjUtd4+WZmQ@mail.gmail.com>
 <20170127151119.GB25829@oracle.com>
 <CAF=yD-+LS6g572Uo5oErq7uazxxPwXXo0w2p4zcHDbXxkuah6Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
        Network Development <netdev@vger.kernel.org>
To: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:45861 "EHLO
        userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754783AbdA0RDe (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 27 Jan 2017 12:03:34 -0500
Content-Disposition: inline
In-Reply-To: <CAF=yD-+LS6g572Uo5oErq7uazxxPwXXo0w2p4zcHDbXxkuah6Q@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On (01/27/17 10:28), Willem de Bruijn wrote:
> > Would it make sense to only do the CAP_SYS_RAWIO branch if the
> > driver declares itself to have variable length L2 headers, via, e.g.,
> > some priv flag?
> 
> At the time, the comments were not specific to AX25. Again, we should
> probably put that bypass behind a flag, enabling validating in the common case.

Just to make sure I'm on the same page as you (since you have more
history with this one..) we are going to have a priv_flags like
IFF_VAR_L2HDR which (today) would only be set for ax25, and 
we would only take the CAP_SYS_RAWIO branch for IFF_VAR_L2HDR, right?

--Sowmini
