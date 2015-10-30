From: =?UTF-8?Q?Maciej_=C5=BBenczykowski?= <zenczykowski@gmail.com>
Subject: Re: [BUG] Any-IP IPv6 support broken
Date: Thu, 29 Oct 2015 17:44:10 -0700
Message-ID: <CAHo-OowqDLe1d+bJEo9B_1AC41n+RM+5Kkq7NknA-CouWoeYAQ@mail.gmail.com>
References: <0977189F-9778-4D1C-939D-FAD71595E5F6@gmail.com>
	<1446132888.7476.153.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Gilberto Bertin <gilberto.bertin@gmail.com>,
	Linux NetDev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f170.google.com ([209.85.217.170]:33409 "EHLO
	mail-lb0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758000AbbJ3AoM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 29 Oct 2015 20:44:12 -0400
Received: by lbbec13 with SMTP id ec13so40817542lbb.0
        for <netdev@vger.kernel.org>; Thu, 29 Oct 2015 17:44:10 -0700 (PDT)
In-Reply-To: <1446132888.7476.153.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

What are you trying to do?

The intent of the patch is to be able to terminate connections from
outside the machine that are reaching the machine (perhaps delivered
inside a tunnel or via some other mechanism: static arp entries,
routing via the machine, etc), that the kernel wouldn't normally think
were destined for the host.

You can't really test it from within the machine (unless you use
network namespaces).

Does what you're trying to do work on an older kernel?  Which kernel
version does it break at?

btw. afaik any-ip doesn't work with IPv4 on any un-patched kernel (the
IPv4 support patch was reverted).
