From: Mark Ryden <markryde@gmail.com>
Subject: skb_warn_if_lro(skb) in ip_forward()
Date: Mon, 27 Apr 2009 09:43:39 +0300
Message-ID: <dac45060904262343v481d2665s4074e901852406b5@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f158.google.com ([209.85.220.158]:56169 "EHLO
	mail-fx0-f158.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754342AbZD0Gnl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Apr 2009 02:43:41 -0400
Received: by fxm2 with SMTP id 2so2104701fxm.37
        for <netdev@vger.kernel.org>; Sun, 26 Apr 2009 23:43:39 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I would appreciate if somebody will explain in a few sentences, why,
when forwarding
a packet in IPV4 , in ip_forward() method, (net/ipv4/ip_forward.c) we
drop the packet
if it is lro.

To be more specific, why do we have, in ip_forward() :
...
...
if (skb_warn_if_lro(skb))
	goto drop;
...
...

Regards,
Mark Ryden
