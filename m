From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: tcp md5: one more crypto-sg-on-the-stack instance
Date: Sat, 25 Jun 2016 06:26:11 +0200
Message-ID: <1466828771.6850.124.camel@edumazet-glaptop3.roam.corp.google.com>
References: <CALCETrXezCXy4N7wMjYdr+U1A9Avda5bVxTxOQZswinh62gbvw@mail.gmail.com>
	 <1466827910.6850.123.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Network Development <netdev@vger.kernel.org>
To: Andy Lutomirski <luto@amacapital.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f44.google.com ([74.125.82.44]:35417 "EHLO
	mail-wm0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750961AbcFYE0O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Jun 2016 00:26:14 -0400
Received: by mail-wm0-f44.google.com with SMTP id v199so41894964wmv.0
        for <netdev@vger.kernel.org>; Fri, 24 Jun 2016 21:26:13 -0700 (PDT)
In-Reply-To: <1466827910.6850.123.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 2016-06-25 at 06:11 +0200, Eric Dumazet wrote:

> Simply extend tcp_md5sig_pool to contain a copy of the TCP headers ?
> 
> At most 40 bytes of extra per cpu storage is not a big problem.
> 

Correction : This is exactly 20 bytes for tcphdr, not 40.
