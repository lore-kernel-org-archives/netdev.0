From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: ipv6: Add IPv6 support to the ping socket.
Date: Tue, 14 May 2013 08:30:54 -0700
Message-ID: <1368545454.4519.13.camel@edumazet-glaptop>
References: <20130514145804.3780F180460@drone2.tok.corp.google.com>
	 <1368544581.4519.12.camel@edumazet-glaptop>
	 <CAKD1Yr0s1pD-BwXcanf-zzHxUUtze6X_dKgL+eyLH0HD46zwHg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	segoon@openwall.com, yoshfuji@linux-ipv6.org,
	Eric Dumazet <edumazet@google.com>
To: Lorenzo Colitti <lorenzo@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:51545 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752627Ab3ENPa5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 May 2013 11:30:57 -0400
Received: by mail-pa0-f52.google.com with SMTP id bg2so619987pad.25
        for <netdev@vger.kernel.org>; Tue, 14 May 2013 08:30:57 -0700 (PDT)
In-Reply-To: <CAKD1Yr0s1pD-BwXcanf-zzHxUUtze6X_dKgL+eyLH0HD46zwHg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-05-15 at 00:22 +0900, Lorenzo Colitti wrote:
> On Wed, May 15, 2013 at 12:16 AM, Eric Dumazet
> <eric.dumazet@gmail.com> wrote:
>         This cannot possibly work with
>         
>         CONFIG_IPV6=m
> 
> 
> Hmm, I thought I did that. I had problems with #if
> IS_ENABLED(CONFIG_IPV6), but I thought #if CONFIG_IPV6 worked. Let me
> try again.

Also remind to send text mails to netdev, not html

Let me try to compile your patch :

  MODPOST 263 modules
ERROR: "ping_init_sock" [net/ipv6/ipv6.ko] undefined!
ERROR: "ping_rcv" [net/ipv6/ipv6.ko] undefined!
ERROR: "ping_close" [net/ipv6/ipv6.ko] undefined!
ERROR: "ping_common_sendmsg" [net/ipv6/ipv6.ko] undefined!
ERROR: "ping_get_port" [net/ipv6/ipv6.ko] undefined!
ERROR: "ping_unhash" [net/ipv6/ipv6.ko] undefined!
ERROR: "ping_bind" [net/ipv6/ipv6.ko] undefined!
ERROR: "ping_err" [net/ipv6/ipv6.ko] undefined!
ERROR: "ping_getfrag" [net/ipv6/ipv6.ko] undefined!
ERROR: "ping_recvmsg" [net/ipv6/ipv6.ko] undefined!
ERROR: "ping_hash" [net/ipv6/ipv6.ko] undefined!
ERROR: "ping_queue_rcv_skb" [net/ipv6/ipv6.ko] undefined!
make[2]: *** [__modpost] Error 1
make[1]: *** [modules] Error 2
make[1]: *** Waiting for unfinished jobs....

Sorry :)
