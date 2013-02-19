From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: SOCK_STREAM TCP: send() returns success even when other side
 responded with RST packet
Date: Tue, 19 Feb 2013 07:26:08 -0800
Message-ID: <20130219072608.7a3a473e@samsung-9>
References: <1361285472.19353.126.camel@edumazet-glaptop>
	<2084007858.1889873.1361286562542.JavaMail.root@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
To: Tomas Hozza <thozza@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ia0-f173.google.com ([209.85.210.173]:41778 "EHLO
	mail-ia0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S933056Ab3BSP0P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Feb 2013 10:26:15 -0500
Received: by mail-ia0-f173.google.com with SMTP id h37so6197939iak.32
        for <netdev@vger.kernel.org>; Tue, 19 Feb 2013 07:26:15 -0800 (PST)
In-Reply-To: <2084007858.1889873.1361286562542.JavaMail.root@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> stack did not yet delivered the data.
> 
> I'm using TCP because it should guarantee that my data were delivered or
> let me know there was some problem. If this is not a bug, then it is at least
> confusing for TCP.
> 
> > To make sure data is delivered, you need additional logic.
> 
> To be honest I didn't find any way how to get notified there was a RST packet
> sent as a reply to my previously sent data.

TCP makes no end-to-end (application to application) guarantees.
Applications that need assurance need to do a request-reply at end of
transaction. You should get a good textbook like Stevens for more detail
