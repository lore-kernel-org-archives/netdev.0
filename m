From: Eric Dumazet <erdnetdev@gmail.com>
Subject: Re: inaccurate packet scheduling
Date: Tue, 18 Dec 2012 08:51:43 -0800
Message-ID: <1355849503.9380.37.camel@edumazet-glaptop>
References: <e2f71dc7-bee5-41ca-bd64-f4569fa953da@tahiti.vyatta.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Jiri Pirko <jiri@resnulli.us>, jhs@mojatatu.com,
	davem@davemloft.net, edumazet@google.com, tgraf@suug.ch,
	netdev@vger.kernel.org
To: Stephen Hemminger <stephen.hemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f53.google.com ([209.85.220.53]:55942 "EHLO
	mail-pa0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932097Ab2LRQvz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Dec 2012 11:51:55 -0500
Received: by mail-pa0-f53.google.com with SMTP id hz1so662511pad.26
        for <netdev@vger.kernel.org>; Tue, 18 Dec 2012 08:51:54 -0800 (PST)
In-Reply-To: <e2f71dc7-bee5-41ca-bd64-f4569fa953da@tahiti.vyatta.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-12-18 at 08:26 -0800, Stephen Hemminger wrote:

> Check kernel log for messages about clock. It could be that on the
> machines with issues TSC is not usable for kernel clock.
> Also turn off TSO since it screws up any form of rate control.

Yes, but we should fix it eventually. I'll take a look.
