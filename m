From: Neal Cardwell <ncardwell@google.com>
Subject: Re: [PATCH net-next] tcp: properly send new data in fast recovery in
 first RTT
Date: Tue, 11 Jun 2013 19:56:28 -0400
Message-ID: <CADVnQymM_fasoZ6s=Si=gccQ=wvmdt+0jryWovTxLeZw8e95WA@mail.gmail.com>
References: <1370990132-27652-1-git-send-email-ycheng@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: David Miller <davem@davemloft.net>,
	Eric Dumazet <edumazet@google.com>,
	Nandita Dukkipati <nanditad@google.com>,
	Netdev <netdev@vger.kernel.org>
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f170.google.com ([209.85.214.170]:64054 "EHLO
	mail-ob0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752686Ab3FKX43 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 Jun 2013 19:56:29 -0400
Received: by mail-ob0-f170.google.com with SMTP id ef5so12717815obb.29
        for <netdev@vger.kernel.org>; Tue, 11 Jun 2013 16:56:28 -0700 (PDT)
In-Reply-To: <1370990132-27652-1-git-send-email-ycheng@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jun 11, 2013 at 6:35 PM, Yuchung Cheng <ycheng@google.com> wrote:
> Linux sends new unset data during disorder and recovery state if all
> (suspected) lost packets have been retransmitted ( RFC5681, section
> 3.2 step 1 & 2, RFC3517 section 4, NexSeg() Rule 2).  One requirement
> is to keep the receive window about twice the estimated sender's
> congestion window (tcp_rcv_space_adjust()), assuming the fast
> retransmits repair the losses in the next round trip.
>
> But currently it's not the case on the first round trip in either
> normal or Fast Open connection, beucase the initial receive window
> is identical to (expected) sender's initial congestion window. The
> fix is to double it.
>
> Signed-off-by: Yuchung Cheng <ycheng@google.com>

Acked-by: Neal Cardwell <ncardwell@google.com>
