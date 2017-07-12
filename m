From: Blake Willis <netdev@2112.net>
Subject: RFC7510 MPLS-over-UDP support in iproute2
Date: Wed, 12 Jul 2017 22:30:45 +0200 (CEST)
Message-ID: <alpine.BSO.2.00.1707122153330.19800@virtsong.2112.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 2112.net ([83.167.57.54]:4153 "EHLO virtsong.2112.net"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753027AbdGLVET (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 12 Jul 2017 17:04:19 -0400
Received: from virtsong.2112.net (blake@virtsong.2112.net [83.167.57.54])
        by virtsong.2112.net (8.14.5/8.14.3) with ESMTP id v6CKUmXn013056
        (version=TLSv1/SSLv3 cipher=DHE-RSA-AES256-SHA bits=256 verify=NO)
        for <netdev@vger.kernel.org>; Wed, 12 Jul 2017 22:30:49 +0200 (CEST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Greetings,

I noticed that MPLS-over-IP & MPLS-over-UDP support have recently been committed 
to the kernel, & that MPLS-over-IP support was commited to iproute2 last week.

Please consider this a humble request for RFC7510 MPLS-over-UDP (UDP port 6635) 
support in iproute2.

Perhaps I'm missing something & this should be doable with the current code?  
The previous iproute2 example on netdev@ ("ip fou add port 6635 ipproto 137") 
seems to indicate that it would be creating an "mpls-over-ip-over-udp" tunnel, 
which wouldn't be compatible with RFC7510, which just adds a simple UDP header 
to MPLS packets (MPLS dataplane packets aren't IP packets & thus don't have an 
IP protocol number, e.g. it uses ethertype 0x8847 for unicast & 0x8848 for 
multicast).

Or perhaps RFC7510 support would be better off as part of the lwtunnel framework?

Thanks & best regards,
---
 Blake Willis
 Network Engineering Consultant
 Scalable System Design LLC
 blake at 2112 dot net

"I think what a lot of people don't appreciate is that technology does not automatically improve. It only improves if a lot of really strong engineering talent is applied to the problem, that it improves. And there are many examples in history where civilizations have reached a certain technology level, and then have fallen well below that, and then recovered only millennia later."

  -- Elon Musk
