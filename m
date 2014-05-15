From: Chptx Young <chptxy@gmail.com>
Subject: why tcp retrancimission continue after FIN flag received?
Date: Thu, 15 May 2014 11:52:55 +0800
Message-ID: <CAMRd1sV1g9wMc1aSgkcCHV+tb_T3Yr-q1XCXoT2XrACLDrY69w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oa0-f66.google.com ([209.85.219.66]:57924 "EHLO
	mail-oa0-f66.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751431AbaEODw4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 May 2014 23:52:56 -0400
Received: by mail-oa0-f66.google.com with SMTP id l6so142258oag.1
        for <netdev@vger.kernel.org>; Wed, 14 May 2014 20:52:56 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

hello,
      these packtes were captured with tcpdump on Android/linux
3.4.39/10.180.43.211, linux
tries retransimissin (packet #35 ) after FIN (#32), any problem here?

     No.     Time        Source                Destination
Protocol Length  Info
     26 17.657176   10.180.43.211         10.0.0.172            TCP
  1466   [TCP segment of a reassembled PDU]
     27 37.630979   10.180.43.211         10.0.0.172            TCP
  1466   [TCP Retransmission] [TCP segment of a reassembled PDU]
     28 40.876444   10.0.0.172            10.180.43.211         TCP
  56     http > 32921 [ACK] Seq=1 Ack=8687 Win=22560 Len=0
     29 40.877060   10.180.43.211         10.0.0.172            TCP
  1466   [TCP segment of a reassembled PDU]
     30 40.877248   10.180.43.211         10.0.0.172            TCP
  1466   [TCP segment of a reassembled PDU]
     31 80.830941   10.180.43.211         10.0.0.172            TCP
  1466   [TCP Retransmission] [TCP segment of a reassembled PDU]
     32 82.723420   10.0.0.172            10.180.43.211         TCP
  56     http > 32921 [FIN, ACK] Seq=1 Ack=8687 Win=22560 Len=0
     33 82.725760   10.180.43.211         10.0.0.172            TCP
  56     32921 > http [ACK] Seq=15737 Ack=2 Win=14600 Len=0
     34 83.536384   10.0.0.172            10.180.43.211         TCP
  56     http > 32921 [RST] Seq=1 Win=0 Len=0
     35 160.831079  10.180.43.211         10.0.0.172            TCP
  1466   [TCP Retransmission] [TCP segment of a reassembled PDU]
