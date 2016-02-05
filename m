From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next 7/7] soreuseport: BPF selection functional test
 for TCP
Date: Thu, 04 Feb 2016 21:40:12 -0800
Message-ID: <1454650812.7627.304.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1454600118-30152-1-git-send-email-kraigatgoog@gmail.com>
	 <1454600118-30152-8-git-send-email-kraigatgoog@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>
To: Craig Gallek <kraigatgoog@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:36030 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751247AbcBEFkO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Feb 2016 00:40:14 -0500
Received: by mail-pa0-f54.google.com with SMTP id yy13so28223989pab.3
        for <netdev@vger.kernel.org>; Thu, 04 Feb 2016 21:40:13 -0800 (PST)
In-Reply-To: <1454600118-30152-8-git-send-email-kraigatgoog@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-02-04 at 10:35 -0500, Craig Gallek wrote:
> From: Craig Gallek <kraig@google.com>
> 
> Unfortunately the existing test relied on packet payload in order to
> map incoming packets to sockets.  In order to get this to work with TCP,
> TCP_FASTOPEN needed to be used.
> 
> Since the fast open path is slightly different than the standard TCP path,
> I created a second test which sends to reuseport group members based
> on receiving cpu core id.  This will probably serve as a better
> real-world example use as well.


Acked-by: Eric Dumazet <edumazet@google.com>
