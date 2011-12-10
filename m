From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Optimizing tc filters
Date: Sat, 10 Dec 2011 20:41:04 +0100
Message-ID: <1323546064.4016.27.camel@edumazet-laptop>
References: <1323540988.3159.133.camel@denise.theartistscloset.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: "John A. Sullivan III" <jsullivan@opensourcedevel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:40471 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751134Ab1LJTlJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 10 Dec 2011 14:41:09 -0500
Received: by eekc4 with SMTP id c4so909828eek.19
        for <netdev@vger.kernel.org>; Sat, 10 Dec 2011 11:41:07 -0800 (PST)
In-Reply-To: <1323540988.3159.133.camel@denise.theartistscloset.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le samedi 10 d=C3=A9cembre 2011 =C3=A0 13:16 -0500, John A. Sullivan II=
I a =C3=A9crit :
> Hello, all.  Given that there are several ways to direct packets into
> the appropriate queue, I was wondering which ways are generally more
> efficient.  There seem to be a number of email discussions but nothin=
g
> authoritative.  From those discussions, it would seem that for most
> corporate usage (as in more traffic than a home user) we would have f=
rom
> most efficient to least efficient:
>=20
> 1) Mark the connection with CONNMARK and us --restore-mark to mark al=
l
> packets in the connection for classification via an fw filter
>=20
> 2) Use the iptables CLASSIFY target
>=20
> 3) u32 filter
>=20
> 4) Mark individual packets and use an fw filter - one email thread sa=
ys
> this is more efficient than #3
>=20
> Is this correct?

Unfortunately CONNTRACK is a bit expensive...

If you control applications, you also can use SO_MARK from them.
