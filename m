From: Prashant Upadhyaya <praupadhyaya@gmail.com>
Subject: Load Balancing for AF_INET Raw Sockets
Date: Tue, 15 Dec 2015 18:26:42 +0530
Message-ID: <CAPBAu3Uz5P-uJ3Hqg=K49PLDkaGtUWW_SGAH0mTvAsevwvE7Ew@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f182.google.com ([209.85.223.182]:36110 "EHLO
	mail-io0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932861AbbLOM4m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Dec 2015 07:56:42 -0500
Received: by mail-io0-f182.google.com with SMTP id o67so17843172iof.3
        for <netdev@vger.kernel.org>; Tue, 15 Dec 2015 04:56:42 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I open a raw socket for listening to all the UDP packets in a raw fashion --

socket(AF_INET, SOCK_RAW, IPPROTO_UDP);

Then I use recvfrom to read the packets over the socket.

The above works mighty fine.
I want to find out if it is possible to 'load balance' the UDP flows
by opening up multiple instances of this socket and then possibly
setting some socket options so that I can scale up the reading via
multiple threads doing recvfrom on these from multiple cores.
(I know it is possible over packet sockets, but that is a different usecase)

Regards
-Prashant
