From: chptx y <chptxy@gmail.com>
Subject: What causes these TCP packet getting lost in linux kernel
Date: Fri, 11 Apr 2014 15:19:41 +0800
Message-ID: <CAMRd1sXbgcGQuBKd6b-wwkrsqgh_4QicfyR=1hh+TqyYUjYHFA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f68.google.com ([209.85.219.68]:45492 "EHLO
	mail-oa0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753323AbaDKHTl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Apr 2014 03:19:41 -0400
Received: by mail-oa0-f68.google.com with SMTP id i7so1485674oag.7
        for <netdev@vger.kernel.org>; Fri, 11 Apr 2014 00:19:41 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I captured these packets with tcpdump on Android device(linux 3.4.39),
these packets are in a HTTP GET Stream:

1  385.447794 Server -> Client: SEQ 12517, LEN 100
2  385.498345 Client -> Server: SEQ 3086, LEN 0, ACK 12617
3  385.497836 Server -> Client: SEQ 12617, LEN 1348
4  385.498644 Client -> Server: [DUP ACK] SEQ 3086, LEN 0, ACK 12617
5  385.498735 Server -> Client: SEQ 13965, LEN 619
6  385.498978 Client -> Server: [Dup ACK] SEQ 3086, LEN 0, ACK 12617
7  385.718843 Server -> Client: [Retrans] SEQ 13965, LEN 619
8  385.719280 Client -> Server: [DUP ACK] SEQ 3086, LEN 0, ACK 12617
9  385.733230 Server -> Client: [Retrans] SEQ 12617, LEN 1348
10 385.733602 Client -> Server: SEQ 3086, LEN 0, ACK 14584
11 385.909921 Server -> Client: [Retrans] SEQ 12617, LEN 1348
12 385.910449 Client -> Server: [DUP ACK][Window Upd.] SEQ 3086, LEN
0, ACK 14584
13 388.031541 Client -> Server: SEQ 832, LEN 0, ACK 4192, FIN
14 388.031681 Client -> Server: SEQ 3086, LEN 0, ACK 14584, FIN

Client is my device run tcpdump on.

packet #3 (SEQ 12617) has been captured yet, Is there any problem in
kernel causes this packet getting lost in upper layer? why does kernel
send packet #4 (DUP ACK) repeatedly?

Thanks.
