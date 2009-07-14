From: Yinglin Sun <yinglin.s@gmail.com>
Subject: [TCP_CA_CWR] Causes for entering TCP_CA_CWR state with 0
	retransmissions
Date: Tue, 14 Jul 2009 14:38:07 -0400
Message-ID: <46bf9ede0907141138q3b665aefv46a18591c3cfc2ce@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f226.google.com ([209.85.219.226]:51219 "EHLO
	mail-ew0-f226.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754220AbZGNSiJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Jul 2009 14:38:09 -0400
Received: by ewy26 with SMTP id 26so3499403ewy.37
        for <netdev@vger.kernel.org>; Tue, 14 Jul 2009 11:38:08 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I have a question about tcp_ca_state "TCP_CA_CWR".  Under what
circumstances does it enter this state?
I'm doing some experiments and have trace from tcp_info. From tcp_info
trace, I found that many places show ca_state is 2 (TCP_CA_CWR). Under
this state, the congestion window size decreases but the total number
of retransmissions is still 0.

I got some explanation from a very old message posted in 2003:
TCP_CA_CWR: The congestion window should be reduced due to some
congestion notification event, which can be ECN, ICMP source quench,
or local device congestion. Both sender and receiver don't have ECN
enabled, so ECN is not the case. ICMP source quench is so out-of-date
with RFC 1812 saying the routers should not issue these packets. So it
might be caused by local congestion. But this post is too old, almost
done 6 years ago. So I want to check if there are other possible
causes in today's kernel leading to TCP_CA_CWR with 0 retransmissions?

I need to find the exact cause for this phenomena, local congestion,
or other possible causes. Any hint will be very helpful for me.

Thanks a lot!

Yinglin
