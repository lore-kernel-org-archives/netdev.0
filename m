From: Yuchung Cheng <ycheng@google.com>
Subject: Re: the congestion window rfc2001
Date: Tue, 13 Aug 2013 07:29:51 -0700
Message-ID: <CAK6E8=fTGuQPZFzq3YWv7mewaJbXFrQQt4pEc5_eWMwyV6-enQ@mail.gmail.com>
References: <520AC2AD.1030306@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev <netdev@vger.kernel.org>
To: Dong Fang <yp.fangdong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f50.google.com ([209.85.219.50]:50898 "EHLO
	mail-oa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756986Ab3HMOaM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Aug 2013 10:30:12 -0400
Received: by mail-oa0-f50.google.com with SMTP id i4so11605665oah.9
        for <netdev@vger.kernel.org>; Tue, 13 Aug 2013 07:30:11 -0700 (PDT)
In-Reply-To: <520AC2AD.1030306@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Please ask those questions on more relevant list such as
tcpm@ietf.org. This list is for discussing Linux kernel networking
development, not generic TCP protocol.

On Tue, Aug 13, 2013 at 4:35 PM, Dong Fang <yp.fangdong@gmail.com> wrote:
> hi, all
>
>
> http://tools.ietf.org/html/rfc2001
>
>
>    1.  When the third duplicate ACK in a row is received, set ssthresh
>        to one-half the current congestion window, cwnd, but no less
>        than two segments.  Retransmit the missing segment.  Set cwnd =
>        ssthresh + 3 times the segment size.  This inflates the
> -- what is the meaning of '3'
>
>        congestion window by the number of segments that have left the
>        network and which the other end has cached (3).
>
>    2.  Each time another duplicate ACK arrives, increment cwnd by the
>        segment size.  This inflates the congestion window for the
>        additional segment that has left the network.
> -- why do this
>
>        Transmit a packet, if allowed by the new value of cwnd.
>
>    3.  When the next ACK arrives that acknowledges new data, set cwnd
>        to ssthresh (the value set in step 1).  This ACK should be the
>        acknowledgment of the retransmission from step 1, one round-trip
>        time after the retransmission.  Additionally, this ACK should
>        acknowledge all the intermediate segments sent between the lost
>        packet and the receipt of the first duplicate ACK.  This step is
>        congestion avoidance, since TCP is down to one-half the rate it
>        was at when the packet was lost.
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
