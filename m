From: Dong Fang <yp.fangdong@gmail.com>
Subject: the congestion window rfc2001
Date: Tue, 13 Aug 2013 19:35:09 -0400
Message-ID: <520AC2AD.1030306@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:38406 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755325Ab3HMLfb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Aug 2013 07:35:31 -0400
Received: by mail-pa0-f46.google.com with SMTP id fa1so6828706pad.5
        for <netdev@vger.kernel.org>; Tue, 13 Aug 2013 04:35:31 -0700 (PDT)
Received: from [192.168.1.108] ([114.249.17.58])
        by mx.google.com with ESMTPSA id eq5sm43370921pbc.15.2013.08.13.04.35.28
        for <netdev@vger.kernel.org>
        (version=TLSv1 cipher=RC4-SHA bits=128/128);
        Tue, 13 Aug 2013 04:35:30 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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
