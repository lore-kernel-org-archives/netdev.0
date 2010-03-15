From: raj ravi <mekaviraj@gmail.com>
Subject: tcp_reordering as 0 possible?
Date: Mon, 15 Mar 2010 19:55:16 +0530
Message-ID: <de0a9dcb1003150725h367d0548j35037441fdb2f5df@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:54475 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S936503Ab0COOZT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Mar 2010 10:25:19 -0400
Received: by vws12 with SMTP id 12so235481vws.19
        for <netdev@vger.kernel.org>; Mon, 15 Mar 2010 07:25:18 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,
what is the behaviour in TCP stack if I set tcp_reordering as 0.
So , sender will  start retransmission without waiting for any duplicate ACK ?
/proc/sys/net/ipv4/tcp_reordering   - Please clarify.
The default value is 3 which means it waits until 3 duplicate ack's
arrive and then start retransmission.

"The TCP sender should use the fast retransmit algorithm to detect and
repair loss based on incoming duplicate ACKs. After the arrival of 3
duplicate ACKs (4 identical ACKs without the arrival of any other
intervening packet), TCP performs a retransmission of what appears to
be the missing segment, without waiting for the retransmission timer
to expire."

Thanks!
Kavi
