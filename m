From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH] ip: Fix ip_dev_loopback_xmit()
Date: Fri, 16 Apr 2010 08:19:23 +0800
Message-ID: <l2q412e6f7f1004151719g7979d181kfd34f1eabd9fdcf9@mail.gmail.com>
References: <1271358783.16881.2949.camel@edumazet-laptop> <20100415.142641.125242830.davem@davemloft.net>
	<w2o412e6f7f1004151703xdcc4da16s4eb6308f2578b531@mail.gmail.com>
	<20100415.171548.179331927.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: eric.dumazet@gmail.com, eparis@redhat.com, netdev@vger.kernel.org,
	therbert@google.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iw0-f197.google.com ([209.85.223.197]:45601 "EHLO
	mail-iw0-f197.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758178Ab0DPATo convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Apr 2010 20:19:44 -0400
Received: by iwn35 with SMTP id 35so976056iwn.21
        for <netdev@vger.kernel.org>; Thu, 15 Apr 2010 17:19:43 -0700 (PDT)
In-Reply-To: <20100415.171548.179331927.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Apr 16, 2010 at 8:15 AM, David Miller <davem@davemloft.net> wro=
te:
>
> The ->hard_start_xmit() method always executes with software
> interrupts disabled.
>

Oh, sorry. I traced to the wrong function.

--=20
Regards=EF=BC=8C
Changli Gao(xiaosuo@gmail.com)
