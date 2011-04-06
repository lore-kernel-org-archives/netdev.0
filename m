From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] ipv6: Enable RFS sk_rxhash tracking for ipv6 sockets
Date: Wed, 06 Apr 2011 20:38:55 +0200
Message-ID: <1302115135.3209.134.camel@edumazet-laptop>
References: <1302112465-6842-1-git-send-email-nhorman@tuxdriver.com>
	 <1302113253.3209.126.camel@edumazet-laptop>
	 <20110406.111712.226782643.davem@davemloft.net>
	 <1302114188.3209.128.camel@edumazet-laptop>
	 <20110406183318.GA6825@hmsreliant.think-freely.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	kuznet@ms2.inr.ac.ru, pekkas@netcore.fi, jmorris@namei.org,
	yoshfuji@linux-ipv6.org, kaber@trash.net, therbert@google.com
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:63972 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756293Ab1DFSjA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 Apr 2011 14:39:00 -0400
Received: by wwa36 with SMTP id 36so2124577wwa.1
        for <netdev@vger.kernel.org>; Wed, 06 Apr 2011 11:38:59 -0700 (PDT)
In-Reply-To: <20110406183318.GA6825@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 06 avril 2011 =C3=A0 14:33 -0400, Neil Horman a =C3=A9crit =
:

> Thats kind of a tricky question, are you referring to clients or serv=
ers?  Both
> should be able to use RFS as Dave notes, but since sockets in NFS cli=
ents tend to be per
> mount, rather than per application (as RFS nominally expects when doi=
ng flow
> steering), theres likely to be some conflict in where RFS decides to =
steer
> packets for that NFS socket  as different applications on different c=
pus make
> use of the same socket.

Yes, maybe there are some updates to make NFS scale better with
multiqueue NICS [ or RPS/RFS ]



