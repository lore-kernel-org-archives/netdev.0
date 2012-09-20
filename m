From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v3] net-tcp: TCP/IP stack bypass for loopback
 connections
Date: Thu, 20 Sep 2012 13:51:11 +0200
Message-ID: <1348141871.31352.66.camel@edumazet-glaptop>
References: <1347908305-13541-1-git-send-email-brutus@google.com>
	 <1347913239.26523.173.camel@edumazet-glaptop>
	 <20120919.163406.487082174277409074.davem@davemloft.net>
	 <1348088634.31352.26.camel@edumazet-glaptop>
	 <CAEkNxbEJjAu3+3yDGPGSzzee-LY_797RdNbBgcC6=-aDHfEAJQ@mail.gmail.com>
	 <505AFDE9.4080602@earthlink.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Bruce Curtis <brutus@google.com>,
	David Miller <davem@davemloft.net>, edumazet@google.com,
	netdev@vger.kernel.org
To: sclark46@earthlink.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:40329 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754004Ab2ITLvQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Sep 2012 07:51:16 -0400
Received: by bkuw11 with SMTP id w11so157243bku.19
        for <netdev@vger.kernel.org>; Thu, 20 Sep 2012 04:51:15 -0700 (PDT)
In-Reply-To: <505AFDE9.4080602@earthlink.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-09-20 at 07:28 -0400, Stephen Clark wrote:
>  
> Does this mean traffic on the loopback interface will not traverse 
> netfilter?
> 

Yes this was already mentioned.

Only the SYN / SYNACK messages will

All data will bypass IP stack, qdisc (if any), loopback driver, and
netfilter.
