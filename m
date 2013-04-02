From: Teto <mattator@gmail.com>
Subject: How to find an available TCP port
Date: Tue, 2 Apr 2013 17:25:58 +0200
Message-ID: <CADHp1Nzgjs5OGXWhs-zy6LZ2wsbspRAc+EW4_J3EsUjOOPCxTA@mail.gmail.com>
Reply-To: mattator@gmail.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f178.google.com ([209.85.220.178]:44494 "EHLO
	mail-vc0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761135Ab3DBPZ6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Apr 2013 11:25:58 -0400
Received: by mail-vc0-f178.google.com with SMTP id hz11so555342vcb.9
        for <netdev@vger.kernel.org>; Tue, 02 Apr 2013 08:25:58 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I would like to do deterministic port-based load balancing, that is
choosing a free port number N so that N % K = X while knowing K and X.

Since I am patching a specific implementation, I would like to check
the availibility of the port without having to check bind() return
value.

I believe the function tcp_lport_inuse ( in this file
http://www.cab.u-szeged.hu/linux/kernel/linux/net/ipv4/tcp.c.html)
does what I wish. I would like to call it from another file but it is
static. So here are my questions:
1st/ Is that the correct function ?
2/ How to use it in another src file ? or do you have any other workaround ?

Sorry if that's too noobish a question, I am not used to kernel
development (yet). I f that's the case redirect me to the proper
mailing list.

Best regards
Matt
