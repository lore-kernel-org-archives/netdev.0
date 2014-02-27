From: ratheesh kannoth <ratheesh.ksz@gmail.com>
Subject: zero copy with PACKET_MMAP
Date: Thu, 27 Feb 2014 12:10:06 +0530
Message-ID: <CAGZFCEF0RB2eHOfgVCyjVDEc4S+jHsdJ+-iQdbC3zek7G5Ahcg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org, linux-net@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f178.google.com ([209.85.160.178]:60686 "EHLO
	mail-yk0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750818AbaB0GkG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 27 Feb 2014 01:40:06 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi ,

The link

https://www.kernel.org/doc/Documentation/networking/packet_mmap.txt
talks about  achieving zero copy. But i find a deep  packet copy ( of
length snaplen= skb->len )  here
http://lxr.free-electrons.com/source/net/packet/af_packet.c#L1841.

Is there anything missing/wrong in my understanding ?


Thanks,
Ratheesh
