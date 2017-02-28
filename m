From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v3 net] net: solve a NAPI race
Date: Tue, 28 Feb 2017 08:57:33 -0800
Message-ID: <1488301053.9415.258.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1488032577.9415.131.camel@edumazet-glaptop3.roam.corp.google.com>
         <1488166294.9415.172.camel@edumazet-glaptop3.roam.corp.google.com>
         <1488205298.9415.180.camel@edumazet-glaptop3.roam.corp.google.com>
         <1488226711.9415.204.camel@edumazet-glaptop3.roam.corp.google.com>
         <20170228081702.35ba7a6a@xeon-e3>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f48.google.com ([74.125.83.48]:35341 "EHLO
        mail-pg0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751323AbdB1Q5g (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 28 Feb 2017 11:57:36 -0500
Received: by mail-pg0-f48.google.com with SMTP id b129so7475568pgc.2
        for <netdev@vger.kernel.org>; Tue, 28 Feb 2017 08:57:35 -0800 (PST)
In-Reply-To: <20170228081702.35ba7a6a@xeon-e3>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2017-02-28 at 08:17 -0800, Stephen Hemminger wrote:

> Maybe just as simple as using irqsave/irqrestore in driver.


CPU can be differents.

irqsave will not help.
