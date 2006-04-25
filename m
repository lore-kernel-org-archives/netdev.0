From: "John Que" <qwejohn@gmail.com>
Subject: determine outgoing interface (eth0,eth1) for a packet according to the dest IP
Date: Tue, 25 Apr 2006 10:31:09 +0300
Message-ID: <ada605fb0604250031r2e4a74e7id0b5079fabde9517@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7BIT
Return-path: <netdev-owner@vger.kernel.org>
Received: from uproxy.gmail.com ([66.249.92.171]:37357 "EHLO uproxy.gmail.com")
	by vger.kernel.org with ESMTP id S1751373AbWDYHbL convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 25 Apr 2006 03:31:11 -0400
Received: by uproxy.gmail.com with SMTP id c2so990359ugf
        for <netdev@vger.kernel.org>; Tue, 25 Apr 2006 00:31:09 -0700 (PDT)
To: netdev@vger.kernel.org
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,
What is the right way to determine on which interface card
(eth0 or eth1) will a packet be sent (according to the dest IP)?

I have a machine with two NICS (eth0 and eth1).
I have 2 different gateways.
I need to know on which interface (eth0 or eth1) will the
packet be send according to the dest IP.
I want to do in in a User Space function.

I think of one way to do this is:
Parse the routing table (/proc/net/route) as is done in
net-tools. (to be more specific rprint_fib() in lib/inet_gr.c
of net-tools.
Than according to the IP address and the netmask check if the
dest IP is for one gatway or the second.
If not - than it is the default gateway.

Is there another way ? Is it the correct way ?
Regards,
John
