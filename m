From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Load Balancing for AF_INET Raw Sockets
Date: Tue, 15 Dec 2015 06:39:36 -0800
Message-ID: <1450190376.8474.28.camel@edumazet-glaptop2.roam.corp.google.com>
References: <CAPBAu3Uz5P-uJ3Hqg=K49PLDkaGtUWW_SGAH0mTvAsevwvE7Ew@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: Prashant Upadhyaya <praupadhyaya@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f42.google.com ([209.85.220.42]:33038 "EHLO
	mail-pa0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751996AbbLOOji (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Dec 2015 09:39:38 -0500
Received: by mail-pa0-f42.google.com with SMTP id ur14so5813794pab.0
        for <netdev@vger.kernel.org>; Tue, 15 Dec 2015 06:39:38 -0800 (PST)
In-Reply-To: <CAPBAu3Uz5P-uJ3Hqg=K49PLDkaGtUWW_SGAH0mTvAsevwvE7Ew@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2015-12-15 at 18:26 +0530, Prashant Upadhyaya wrote:
> Hi,
> 
> I open a raw socket for listening to all the UDP packets in a raw fashion --
> 
> socket(AF_INET, SOCK_RAW, IPPROTO_UDP);
> 
> Then I use recvfrom to read the packets over the socket.
> 
> The above works mighty fine.
> I want to find out if it is possible to 'load balance' the UDP flows
> by opening up multiple instances of this socket and then possibly
> setting some socket options so that I can scale up the reading via
> multiple threads doing recvfrom on these from multiple cores.
> (I know it is possible over packet sockets, but that is a different usecase)

No plan yet to support fanout on multiple raw sockets.
