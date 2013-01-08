From: Madhvapathi Sriram <sriram.madhvapathi@gmail.com>
Subject: IPV4 TCP connection reset using iperf
Date: Tue, 8 Jan 2013 20:11:17 +0530
Message-ID: <CAAvRe=izMJWEFDcZYEoJCY2Em7NQKco4_6x1L7t4h2XSJf6_Sg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ie0-f179.google.com ([209.85.223.179]:39565 "EHLO
	mail-ie0-f179.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756428Ab3AHOlR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 8 Jan 2013 09:41:17 -0500
Received: by mail-ie0-f179.google.com with SMTP id k14so560869iea.10
        for <netdev@vger.kernel.org>; Tue, 08 Jan 2013 06:41:17 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I have recently migrated to kernel version 3.6.10 from 3.2.1. I was
running iperf to routinely measure TCP throughput and I have been
facing problems eversince. I am using a wireless interface.

wireless client: iperf -s -i 1 -w 1024K
wireless server: iperf -c 192.168.1.1 -i -1 -w 1024 -t 600

While, the connection is maintained for sometime and the perf logs
keep going. Randomly, the connection breaks with the server side
resetting the connection. The tcp dump on the client shows RST sent by
the server. Switching back to 3.2.1 works. This issue starts from
kernel version 3.5 onnwards.

I have tried to probe along some points to take a look at the air
logs, tcpdump on either sides but to no clue - everything seems normal
like, the tcp window values, very less/negligible retransmissions and
so on. The RST is set abruptly and randomly (no definite time - may
happen randomly).

I am looking for some suggestions or pointers towards analyzing the issue.

Thanks and regards,
Madhvapathi Sriram
