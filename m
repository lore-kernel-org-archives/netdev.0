From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next-2.6] net: inet_add_protocol() can use cmpxchg()
Date: Thu, 09 Sep 2010 08:55:45 +0200
Message-ID: <1284015345.2428.37.camel@edumazet-laptop>
References: <20100909064222.GA6951@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, jesse@nicira.com,
	netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:43709 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752608Ab0IIGzw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 9 Sep 2010 02:55:52 -0400
Received: by fxm16 with SMTP id 16so687709fxm.19
        for <netdev@vger.kernel.org>; Wed, 08 Sep 2010 23:55:51 -0700 (PDT)
In-Reply-To: <20100909064222.GA6951@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 09 septembre 2010 =C3=A0 06:42 +0000, Jarek Poplawski a =C3=A9=
crit :
> Of course, each case is different, but generally I understand Jesse's
> concern. Smaller data section argument shouldn't be enough. There is
> some reason we do it in C not asm, and there is some cost of
> unreadable code too.

Sure, but is cmpxchg() really not readable for you ? ;)

Now it is available for all arches, you can bet it is going to be
adopted.



