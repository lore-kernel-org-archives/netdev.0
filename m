From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [RFC iproute2] sch_red: TC_RED_HARDDROP
Date: Wed, 30 Nov 2011 21:25:49 +0100
Message-ID: <1322684749.2602.3.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Stephen Hemminger <shemminger@vyatta.com>
To: Thomas Graf <tgraf@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:54078 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751882Ab1K3UZy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2011 15:25:54 -0500
Received: by eaak14 with SMTP id k14so1175647eaa.19
        for <netdev@vger.kernel.org>; Wed, 30 Nov 2011 12:25:52 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Thomas

In 2005, TC_RED_HARDDROP kernel support was added to RED and GRED
(commit bdc450a0bb1 [PKT_SCHED]: (G)RED: Introduce hard dropping), but
current iproute2 doesnt have user land support.

Is there some patch waiting somewhere, or should we :

- Remove kernel support, since nobody uses it.

- Add iproute2 support.

Thanks
