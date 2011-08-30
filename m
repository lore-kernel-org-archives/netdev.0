From: Viral Mehta <viral.vkm@gmail.com>
Subject: interface information for recvd packet
Date: Tue, 30 Aug 2011 11:55:58 -0400
Message-ID: <CANX6Dan9szv1w8QTFTob53jt7Bq6jgTtbaHVirvBDJOjH7Uy+w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qy0-f174.google.com ([209.85.216.174]:61636 "EHLO
	mail-qy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755509Ab1H3Pz7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Aug 2011 11:55:59 -0400
Received: by qyk15 with SMTP id 15so1760897qyk.19
        for <netdev@vger.kernel.org>; Tue, 30 Aug 2011 08:55:59 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

I was trying to implement following thing,

1. I wanted to know whenever packet received for particular socket, I
want to know which network interface actually received it ?
2. I was looking at net/ipv4/tcp.c and in function tcp_recvmsg(); I am
trying to get interface name by accessing sk_buff->dev->name
    However, it gives me (null). I have made sure that in my ethernet
(NIC) driver, I filled up that information before doing netif_rx().

So, the question is,
Is this information Trimmed out at some upper layer ??

Thanks,




-- 
Thanks,
Viral Mehta
