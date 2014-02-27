From: Sharat Masetty <sharat04@gmail.com>
Subject: Packet drops observed @ LINUX_MIB_TCPBACKLOGDROP
Date: Wed, 26 Feb 2014 19:00:14 -0700
Message-ID: <CAJzFV35=wUOA+pQCkAwV2+oF79VAmbsRY08gZUiFz-Vtw-898w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f171.google.com ([209.85.212.171]:60707 "EHLO
	mail-wi0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754516AbaB0CAP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 26 Feb 2014 21:00:15 -0500
Received: by mail-wi0-f171.google.com with SMTP id cc10so6652494wib.4
        for <netdev@vger.kernel.org>; Wed, 26 Feb 2014 18:00:14 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

We are trying to achieve category 4 data rates on an ARM device. We
see that with an incoming TCP stream(IP packets coming in and acks
going out) lots of packets are getting dropped when the backlog queue
is full. This is impacting overall data TCP throughput. I am trying to
understand the full context of why this queue is getting full so
often.

>From my brief look at the code, it looks to me like the user space
process is slow and busy in pulling the data from the socket buffer,
therefore the TCP stack is using this backlog queue in the mean time.
This queue is also charged against the main socket buffer allocation.

Can you please explain this backlog queue, and possibly confirm if my
understanding this  matter is accurate?
Also can you suggest any ideas on how to mitigate these drops?

Thanks,
Sharat
