From: vincent Richard <vincent.richard449@gmail.com>
Subject: bnx2x multicast packet loss on igmp join/leave
Date: Fri, 5 Apr 2013 12:13:48 +0200
Message-ID: <CABVbdp_R7H5tWfFUF_8c=4GWLC80Vr8SajZskc8C51Hduue49Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f175.google.com ([209.85.216.175]:49566 "EHLO
	mail-qc0-f175.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751469Ab3DEKUM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Apr 2013 06:20:12 -0400
Received: by mail-qc0-f175.google.com with SMTP id j3so1130656qcs.6
        for <netdev@vger.kernel.org>; Fri, 05 Apr 2013 03:20:11 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I all,

I am using a HP server with bnx2x ethernet cards in it.
I have compiled the latest linux 3.2 version, and I am encountering
the following error :

when joining or leaving a multicast group, other multicast streams
lose some packets.

I tried latest firmware and different drivers (latest HP recommended
one (redhat one)) but still the same..

I observe that putting the interface in promiscuous mode make the
problem disappear.

looking around bnx2x_set_rx_mode, i notice that there is 3 rx_mode,
NORMAL, PROMISCUOUS and ALLMULTI . forcing other than normal mode
correct my issue..

My bnx2x is in a blade center so there is a switch just after. So
forcing PROMISCUOUS or ALLMULTI mode have no major impact.

To reproduce the problem I just "listen" 2 multicast streams and
join/leave another one periodically.

Thanks in advance for your help.
Regards,
Vincent
