From: LovelyLich <lovelylich@gmail.com>
Subject: Why we discard all rtt samples when only some of the acked skbs have
 been retransmited in processing ack?
Date: Tue, 17 Sep 2013 12:01:28 +0800
Message-ID: <CAAA3+BpsxtyM2uAvX6B4ys73ZC6fX5K1ib3Acsk0fp5cQBNgWg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f180.google.com ([209.85.220.180]:35637 "EHLO
	mail-vc0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751086Ab3IQEB3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Sep 2013 00:01:29 -0400
Received: by mail-vc0-f180.google.com with SMTP id ld13so1370735vcb.11
        for <netdev@vger.kernel.org>; Mon, 16 Sep 2013 21:01:28 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Eric,

In tcp_clean_rtx_queue(), we set the flag FLAG_RETRANS_DATA_ACKED when we

encounter one ever retransmited skb A. But if there is one( or more) skb B

after this retransmited skb, and we calculate the rtt for skb B. The question

is because we have set the flag FLAG_RETRANS_DATA_ACKED, and we will just

return in tcp_ack_no_tstamp() !

Two questions:

1. if we will just ignore all packets in this ack, we do not need to calculate

skb B's rtt sample.

2. what I want to know, even if A's rtt sample is not reliable, but B's rtt

sample can be trusted. Why we discard it ?



Thanks in advanced.





regards,

Yi
