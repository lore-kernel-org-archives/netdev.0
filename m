From: Mark Ryden <markryde@gmail.com>
Subject: LRO (Large Receice Offload) and UDP
Date: Sat, 20 Mar 2010 13:15:34 +0200
Message-ID: <dac45061003200415o1fcb1771xb2c43a98c2232c5d@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: themann@de.ibm.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f209.google.com ([209.85.218.209]:42868 "EHLO
	mail-bw0-f209.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751305Ab0CTLPg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 20 Mar 2010 07:15:36 -0400
Received: by bwz1 with SMTP id 1so656531bwz.21
        for <netdev@vger.kernel.org>; Sat, 20 Mar 2010 04:15:34 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I have a question about LRO ("Large Receive Offload") and I will
appreciate if somebody can answer in short (for me, 2-3 sentences are
enough). I have
noticed that LRO handles only TCP packets. Thus, the TCP flag is checked and
non TCP packets are not handled by LRO.
(see the check of LRO_TCP in __lro_proc_skb(), net/ipv4/inet_lro.c).

My question is: why can't the LRO mechanism be applied to UDP ? Or can
it be applied, but is not implemented yet or does not worth to be applied ?

Rgs,
Mark
