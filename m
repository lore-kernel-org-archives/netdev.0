From: Ajith Adapa <adapa.ajith@gmail.com>
Subject: Regarding bottlenecks for high speed packet generation
Date: Thu, 25 Oct 2012 23:16:56 +0530
Message-ID: <CADAe=+KJ2QuL7ZdrfDWQe8R1vF_r_bu3QBS-5kwZBgQ21QTMtg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:34830 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758485Ab2JYRr0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Oct 2012 13:47:26 -0400
Received: by mail-pa0-f46.google.com with SMTP id hz1so1333908pad.19
        for <netdev@vger.kernel.org>; Thu, 25 Oct 2012 10:47:26 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I am trying out a sample application written based on packet_mmap to
generate packets at line rates. I am using 3.4.10 kernel and a gigabit
nic card.
I have found some strange issues as mentioned below.

When I am transmitting packets sized 1500 bytes the socket buffers are
easily filled up eventhough if I increase the value of wmem_default
and wmem_max.
The memory I have allotted can fit around 14k packets of 1500 bytes
size. Is the NIC card not able to transmit them ?? How can I check it
??
I have even increased the Hardware tx queue size of NIC card from 256
to 4096 using ethtool.

Does traffic control causing any issue as I read it wont allow traffic bursts ?

Is there any way to find the major bottlenecks that would really cause
problems in high-speed packet generation.

Regards,
Ajith
