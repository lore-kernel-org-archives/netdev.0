From: Rayagond Kokatanur <rayagond@vayavyalabs.com>
Subject: basic question about LRO implementation
Date: Tue, 22 Apr 2014 13:28:55 +0530
Message-ID: <CAJ3bTp5v5jbpfnc78YXXEbYxOYpWnkz7UioznwszrvqcuHjD=Q@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qa0-f51.google.com ([209.85.216.51]:38342 "EHLO
	mail-qa0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751562AbaDVH64 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Apr 2014 03:58:56 -0400
Received: by mail-qa0-f51.google.com with SMTP id j7so4783295qaq.10
        for <netdev@vger.kernel.org>; Tue, 22 Apr 2014 00:58:55 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi All,

As part of LRO support, every Ethernet driver has to implement a call
back function ".get_skb_header" which does following,

1. Checks for TCP packet and return 0 for TCP packet and -1 for non-tcp packets
2. Get tcp and ip header from given skb
3. Initialize the flag to indicate IPv4 and  TCP packet.

All these can be done by using skb - which is passed as input argument
to get_skb_header, there is nothing device specific we do in this api,
hence why can't this be implemented as generic api. By this way we can
avoid every driver implementing same api and hence duplicating the
same code.

Please let me know if my understanding may be wrong.

Thanks
Rayagond
