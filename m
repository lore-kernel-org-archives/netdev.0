From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next] net: bcmgenet: use napi_complete_done()
Date: Fri, 08 Apr 2016 22:27:27 -0700
Message-ID: <1460179647.6473.478.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1460178400.6473.469.camel@edumazet-glaptop3.roam.corp.google.com>
	 <5B66FA2B-6AAE-4FEB-B5FB-C5C9DF48FDB5@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>,
	Petri Gynther <pgynther@google.com>, opendmb@gmail.com
To: Florian Fainelli <f.fainelli@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f52.google.com ([209.85.192.52]:34275 "EHLO
	mail-qg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750897AbcDIF1a (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Apr 2016 01:27:30 -0400
Received: by mail-qg0-f52.google.com with SMTP id c6so107192249qga.1
        for <netdev@vger.kernel.org>; Fri, 08 Apr 2016 22:27:30 -0700 (PDT)
In-Reply-To: <5B66FA2B-6AAE-4FEB-B5FB-C5C9DF48FDB5@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2016-04-08 at 22:19 -0700, Florian Fainelli wrote:

> Along the same line of changes, we could use napi_schedule_irqoff since NAPI is always scheduled from ISR context.

Good point, I'll cook the patch ;)

Thanks !
