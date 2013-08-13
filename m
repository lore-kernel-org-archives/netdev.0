From: Dong Fang <yp.fangdong@gmail.com>
Subject: the congestion window rfc2001
Date: Tue, 13 Aug 2013 19:58:34 -0400
Message-ID: <520AC82A.5040303@gmail.com>
References: <520AC2AD.1030306@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, Dong Fang <yp.fangdong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f51.google.com ([209.85.220.51]:46522 "EHLO
	mail-pa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757512Ab3HML6y (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Aug 2013 07:58:54 -0400
Received: by mail-pa0-f51.google.com with SMTP id lf1so5989555pab.10
        for <netdev@vger.kernel.org>; Tue, 13 Aug 2013 04:58:53 -0700 (PDT)
In-Reply-To: <520AC2AD.1030306@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>




-------- Original Message --------
Subject: the congestion window rfc2001
Date: Tue, 13 Aug 2013 19:35:09 -0400
From: Dong Fang <yp.fangdong@gmail.com>
To: netdev@vger.kernel.org

hi, all


http://tools.ietf.org/html/rfc2001


    1.  When the third duplicate ACK in a row is received, set ssthresh
        to one-half the current congestion window, cwnd, but no less
        than two segments.  Retransmit the missing segment.  Set cwnd =
        ssthresh + 3 times the segment size.  This inflates the
-- what is the meaning of '3'

        congestion window by the number of segments that have left the
        network and which the other end has cached (3).

    2.  Each time another duplicate ACK arrives, increment cwnd by the
        segment size.  This inflates the congestion window for the
        additional segment that has left the network.
-- why do this

        Transmit a packet, if allowed by the new value of cwnd.

    3.  When the next ACK arrives that acknowledges new data, set cwnd
        to ssthresh (the value set in step 1).  This ACK should be the
        acknowledgment of the retransmission from step 1, one round-trip
        time after the retransmission.  Additionally, this ACK should
        acknowledge all the intermediate segments sent between the lost
        packet and the receipt of the first duplicate ACK.  This step is
        congestion avoidance, since TCP is down to one-half the rate it
        was at when the packet was lost.
