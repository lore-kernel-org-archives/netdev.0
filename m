From: Kieran Kunhya <kierank@ob-encoder.com>
Subject: bnx2 udp multicast packet loss and jtter
Date: Sat, 11 Jun 2011 15:32:04 +0100
Message-ID: <BANLkTimCgWSANaje4aBE5gQdwKWNRJX40A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:53975 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757668Ab1FKOcF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 11 Jun 2011 10:32:05 -0400
Received: by ywe9 with SMTP id 9so1368220ywe.19
        for <netdev@vger.kernel.org>; Sat, 11 Jun 2011 07:32:05 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I get some bad packet loss and high jitter on a BCM5709. This is on
kernel 2.6.38-8 - unfortunately using a newer kernel isn't an option
right now.
The bnx2 driver is version v2.0.23b.

I've tried a lot of kenel types such as -lowlatency, -ck and vanilla.
The thread doing the udp output is at realtime priority and the same
thing happens with different applications.

Example of jitter
http://dl.dropbox.com/u/2701213/jitter.png

Is there anything I can do to further diagnose this problem?

Regards,

Kieran Kunhya
