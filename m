From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: DSCP values in TCP handshake
Date: Mon, 18 Apr 2011 16:05:12 +0200
Message-ID: <1303135512.3137.335.camel@edumazet-laptop>
References: <loom.20110418T154445-102@post.gmane.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Joe Buehler <aspam@cox.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:52053 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754260Ab1DROFQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 Apr 2011 10:05:16 -0400
Received: by wwa36 with SMTP id 36so5708177wwa.1
        for <netdev@vger.kernel.org>; Mon, 18 Apr 2011 07:05:15 -0700 (PDT)
In-Reply-To: <loom.20110418T154445-102@post.gmane.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 18 avril 2011 =C3=A0 13:48 +0000, Joe Buehler a =C3=A9crit :
> What does the LINUX network code put in the DSCP field of TCP SYN-ACK=
 packets
> that are replies to a SYN connection request?  I have a customer send=
ing SYN
> with 0x2e in the DSCP field but apparently getting DSCP 0x0 in the re=
ply.

The other way (server->client) is depending on application and listener
only.

If it uses a standard socket, standard bind() + listen(), TOS is 0



