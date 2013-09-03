From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] ipv6: Don't depend on per socket memory for
 neighbour discovery messages
Date: Tue, 03 Sep 2013 10:51:37 -0700
Message-ID: <1378230697.7360.38.camel@edumazet-glaptop>
References: <e4600dac657e1160da7a5e7758dcb973b616a10e.1378207925.git.tgraf@suug.ch>
	 <52261A12.3060203@wwwdotorg.org>
	 <20130903172736.GB21729@order.stressinduktion.org>
	 <52261F68.70907@wwwdotorg.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Thomas Graf <tgraf@suug.ch>, davem@davemloft.net,
	netdev@vger.kernel.org, Fabio Estevam <festevam@gmail.com>
To: Stephen Warren <swarren@wwwdotorg.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f178.google.com ([209.85.192.178]:37614 "EHLO
	mail-pd0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756594Ab3ICRvi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Sep 2013 13:51:38 -0400
Received: by mail-pd0-f178.google.com with SMTP id w10so6367332pde.9
        for <netdev@vger.kernel.org>; Tue, 03 Sep 2013 10:51:37 -0700 (PDT)
In-Reply-To: <52261F68.70907@wwwdotorg.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2013-09-03 at 11:42 -0600, Stephen Warren wrote:

> I don't see any extra messages from PROVE_LOCKING related to networking.
> There is a single extra message from inside the audio driver, but that's
> not networking-related at all.

LOCKDEP is automatically disabled at first splat.

Please try a kernel without audio driver ;)
