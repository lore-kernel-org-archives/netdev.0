From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Bug with IPv6-UDP address binding
Date: Thu, 09 Aug 2012 13:48:46 +0200
Message-ID: <1344512926.28967.743.camel@edumazet-glaptop>
References: <1344458238.3069.13.camel@localhost>
	 <1344459591.28967.271.camel@edumazet-glaptop>
	 <1344505205.3069.55.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Thomas Graf <tgraf@suug.ch>
To: Jesper Dangaard Brouer <brouer@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:63504 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757551Ab2HILsv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Aug 2012 07:48:51 -0400
Received: by bkwj10 with SMTP id j10so133477bkw.19
        for <netdev@vger.kernel.org>; Thu, 09 Aug 2012 04:48:50 -0700 (PDT)
In-Reply-To: <1344505205.3069.55.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-08-09 at 11:40 +0200, Jesper Dangaard Brouer wrote:

> Guess I should have read Stephens[1] first, as this problem with
> multihomed hosts is described  (on page 219).  He also states, that this
> is a problem/feature related to Berkely-derived implementations.  E.g.
> Solaris handle this, the way I expected. That is, the source IP address
> for the server's reply is the dest IP of the client's request.

Are you sure ?

So Solaris remembers in socket structure the destination IP address of
last UDP message delivered to userland ?

This is not multi thread safe, so it would be a very bad idea.
