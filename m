From: =?ISO-8859-2?Q?Igor_Maravi=E6?= <igorm@etf.rs>
Subject: Testing server performance
Date: Fri, 9 Dec 2011 16:26:32 +0100
Message-ID: <CAFdo_mW0sKSZp3L75BOPBN1Sa+ZQ8WiBRC98eFLM5BaxCVrpJQ@mail.gmail.com>
Reply-To: igorm@etf.rs
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.etf.rs ([147.91.14.170]:37774 "EHLO mx2.etf.bg.ac.rs"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752353Ab1LIP0i (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 9 Dec 2011 10:26:38 -0500
Received: from localhost (avs2.etf.rs [147.91.14.173])
	by mx2.etf.bg.ac.rs (Postfix) with ESMTP id 99B2F60144
	for <netdev@vger.kernel.org>; Fri,  9 Dec 2011 16:26:36 +0100 (CET)
Received: from mx2.etf.bg.ac.rs ([147.91.14.170])
	by localhost (avs2.etf.rs [147.91.14.171]) (amavisd-new, port 10026)
	with ESMTP id 8HU2TPjlbONg for <netdev@vger.kernel.org>;
	Fri,  9 Dec 2011 16:26:35 +0100 (CET)
Received: from mail-pz0-f46.google.com (mail-pz0-f46.google.com [209.85.210.46])
	(using TLSv1 with cipher RC4-SHA (128/128 bits))
	(No client certificate requested)
	(Authenticated sender: igorm)
	by mx2.etf.bg.ac.rs (Postfix) with ESMTP id 0931F6013A
	for <netdev@vger.kernel.org>; Fri,  9 Dec 2011 16:26:34 +0100 (CET)
Received: by dadw7 with SMTP id w7so548902dad.19
        for <netdev@vger.kernel.org>; Fri, 09 Dec 2011 07:26:32 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi all,
I'm currently testing how much traffic can I push through my server.
I'm running on Ubuntu 11.10 server with net-next kernel.
I'm using 2 Gbps NICs, Netgear GA311 and D-Link DGE-528T, that use r8169 driver.
I'm generating UDP packets from a router with constant speed.

After I push traffic to my server with max speed, it saturates.
It receives packets at 77MBps and it sends packet with 14MBps.
When there are no incoming traffic, but there are remaining packets in
tx fifo queue, it sends them with 40MBps.

That all wouldn't be strange because my machine isn't any thing special
(AMD Athlon(tm) II X2 240 on 2,8GHz, motherboard ASUS M2N68 PLUS and
2x2GB DDR2 RAM memory on 1066MHz),
but the dstat shows that CPUs are maximally using 6% of their
resources for interrupt handling.
Beside that, nothing else is using CPU time.
Why does it saturate on this values then? Am I doing something wrong?
Any help is appreciated.

BR
Igor

PS. Kernel is SMP enabled and I tried different bit masks for
smp_affinity for my interfaces, but I still got the same result.
