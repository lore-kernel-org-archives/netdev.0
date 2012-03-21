From: Vincent Li <vincent.mc.li@gmail.com>
Subject: Piggyback the final ACK of the three way TCP connection establishment
 with the data
Date: Wed, 21 Mar 2012 16:38:15 -0700
Message-ID: <CAK3+h2zYLsWw44cAqJN_7vE1bqbEEsDK5oqKLpej0RLuKhk3qQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:51071 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750779Ab2CUXiQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Mar 2012 19:38:16 -0400
Received: by wejx9 with SMTP id x9so1374116wej.19
        for <netdev@vger.kernel.org>; Wed, 21 Mar 2012 16:38:15 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I happen to see this link
http://h20000.www2.hp.com/bc/docs/support/SupportManual/c02020743/c02020743.pdf
and

tcp_delay_final_twh_ack:
            Piggyback the final ACK of the three way TCP connection
            establishment with the data by delaying the final ack by
           10ms.

           0: Send the final ACK as soon as the SYN+ACK packet
               arrives from the remote host.

           1: Delay the sending of the final ACK by 10ms. If
               there is data available to be sent with in the
               next 10ms, piggyback the ACK for the SYN.
[0-1] Default: 1

It appears this feature is not available in kernel tcp implementation,
is it trivial to make a custom patch to make this feature available?
can someone give a hint on how to make a patch for this?

We had a situation that we want to make linux kernel tcp stack behave
this way so we can reproduce another issue at hand.

Thanks

Vincent
