From: Yuchung Cheng <ycheng@google.com>
Subject: Re: [PATCH net-next] tcp: snmp stats for Fast Open, SYN rtx, and data pkts
Date: Mon, 3 Mar 2014 12:38:13 -0800
Message-ID: <CAK6E8=dRMC34jOqB0a1aMZ4=P4hZ0oCLMsTTvZK=hDo+20FkYA@mail.gmail.com>
References: <1393627642-19302-1-git-send-email-ycheng@google.com>
 <1393632473.26794.90.camel@edumazet-glaptop2.roam.corp.google.com> <20140303.152708.479281530254240667.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	netdev <netdev@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>,
	Nandita Dukkipati <nanditad@google.com>,
	Lawrence Brakmo <brakmo@google.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f182.google.com ([209.85.223.182]:53980 "EHLO
	mail-ie0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754159AbaCCUiz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Mar 2014 15:38:55 -0500
Received: by mail-ie0-f182.google.com with SMTP id y20so3894774ier.41
        for <netdev@vger.kernel.org>; Mon, 03 Mar 2014 12:38:55 -0800 (PST)
In-Reply-To: <20140303.152708.479281530254240667.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 3, 2014 at 12:27 PM, David Miller <davem@davemloft.net> wrote:
>
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Fri, 28 Feb 2014 16:07:53 -0800
>
> > On Fri, 2014-02-28 at 14:47 -0800, Yuchung Cheng wrote:
> >> Add the following snmp stats:
> >>
> >> TCPFastOpenActiveFail: Fast Open attempts (SYN/data) failed beacuse
> >> the remote does not accept it or the attempts timed out.
> >>
> >> TCPSynRetrans: number of SYN and SYN/ACK retransmits to break down
> >> retransmissions into SYN, fast-retransmits, timeout retransmits, etc.
> >>
> >> TCPOrigDataSent: number of outgoing packets with original data (excluding
> >> retransmission but including data-in-SYN). This counter is different from
> >> TcpOutSegs because TcpOutSegs also tracks pure ACKs. TCPOrigDataSent is
> >> more useful to track the TCP retransmission rate.
> >>
> >> Change TCPFastOpenActive to track only successful Fast Opens to be symmetric to
> >> TCPFastOpenPassive.
> >>
> >> Signed-off-by: Yuchung Cheng <ycheng@google.com>
> >> Signed-off-by: Eric Dumazet <edumazet@google.com>
> >> Signed-off-by: Nandits Dukkipati <nanditad@google.com>
> >
> > s/Nandits/Nandita/
> >
> >> Signed-off-by: Larry Brakmo <brakmo@google.com>
>
> s/Larry/Lawrence/
>
> Yuchung can you correct your co-worker's names and resubmit?

Submitted a v2. Thanks!
>
>
> Thanks!
