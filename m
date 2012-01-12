From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Consequences of commit 16e5726269611b71c930054ffe9b858c1cea88eb
Date: Thu, 12 Jan 2012 21:59:03 +0100
Message-ID: <1326401943.2617.0.camel@edumazet-laptop>
References: <CAO+b5-pGcKbTYQWdWo=kbiQ2ORbgn8GAV_cfYjGzOARmgrsUxQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Mike Christie <michaelc@cs.wisc.edu>,
	Eric Paris <eparis@redhat.com>
To: Bart Van Assche <bvanassche@acm.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:60954 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755088Ab2ALU7H (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Jan 2012 15:59:07 -0500
Received: by werm1 with SMTP id m1so1710394wer.19
        for <netdev@vger.kernel.org>; Thu, 12 Jan 2012 12:59:06 -0800 (PST)
In-Reply-To: <CAO+b5-pGcKbTYQWdWo=kbiQ2ORbgn8GAV_cfYjGzOARmgrsUxQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 12 janvier 2012 =C3=A0 19:14 +0000, Bart Van Assche a =C3=A9cr=
it :
> Hi,
>=20
> If my analysis is correct commit
> 16e5726269611b71c930054ffe9b858c1cea88eb ("af_unix: dont send
> SCM_CREDENTIALS by default") changes the value of
> NETLINK_CREDS(skb)->pid from the sender pid into zero. Does that mean
> that the code using that construct did work in kernel 3.1 but that it
> is broken in kernel 3.2 ? Should that commit be reverted or will
> someone fix the code that uses NETLINK_CREDS() ? Would changing
> NETLINK_CREDS(skb)->pid into NETLINK_CB(skb).pid be sufficient ?
>=20
> Thanks,
>=20
> Bart.
>=20
> $ git grep 'NETLINK_CREDS([a-zA-Z0-9_]*)->pid'
> drivers/scsi/scsi_netlink.c:	pid =3D NETLINK_CREDS(skb)->pid;
> kernel/audit.c:	pid  =3D NETLINK_CREDS(skb)->pid;


What is your problem exactly ?
