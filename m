From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Fw: Linux tcp_xmit_retransmit_queue use after free on 4.8-rc1 /
 master]
Date: Tue, 16 Aug 2016 08:39:00 -0700
Message-ID: <1471361940.4943.4.camel@edumazet-glaptop3.roam.corp.google.com>
References: <20160816104551.GA28052@kroah.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Marco Grassi <marco.gra@gmail.com>
To: Greg KH <gregkh@linuxfoundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f180.google.com ([209.85.192.180]:33435 "EHLO
	mail-pf0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753276AbcHPPjH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 16 Aug 2016 11:39:07 -0400
Received: by mail-pf0-f180.google.com with SMTP id y134so28707124pfg.0
        for <netdev@vger.kernel.org>; Tue, 16 Aug 2016 08:39:04 -0700 (PDT)
In-Reply-To: <20160816104551.GA28052@kroah.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-08-16 at 12:45 +0200, Greg KH wrote:
> For some reason Marco's emails can't make it to netdev, so I'm
> forwarding this on.  Please cc: him on responses.

Thanks for the report Greg and Marco.

My first guess is this is caused by 

d41a69f1d390 tcp: make tcp_sendmsg() aware of socket backlog

And a combination of funky sendmsg() flags (like FastOpen)

I will look at this problem today.
