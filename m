From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 3/3] ipip: add module alias for tunl0 tunnel device
Date: Tue, 30 Nov 2010 17:27:28 +0100
Message-ID: <1291134448.2904.133.camel@edumazet-laptop>
References: <20101129194746.724222156@vyatta.com>
	 <20101129194805.851988995@vyatta.com>
	 <1291101577.2725.41.camel@edumazet-laptop>
	 <AANLkTi=DFN=r5XLYEwb3RYOyTF+u0uTEUa3wX5i2ijJZ@mail.gmail.com>
	 <1291105269.2725.52.camel@edumazet-laptop>
	 <20101130080842.685e0b70@nehalam>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Changli Gao <xiaosuo@gmail.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:46208 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752451Ab0K3Q1d (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Nov 2010 11:27:33 -0500
Received: by wyb28 with SMTP id 28so5862935wyb.19
        for <netdev@vger.kernel.org>; Tue, 30 Nov 2010 08:27:32 -0800 (PST)
In-Reply-To: <20101130080842.685e0b70@nehalam>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 30 novembre 2010 =C3=A0 08:08 -0800, Stephen Hemminger a =C3=A9=
crit :

> If you run debian there is a list of aliases in /etc/modprobe.d/alias=
es.conf
> that includes the ipip alias.
>=20
> My patch provides same information from the kernel. In olden times,
> the kernel relied more on user space defined aliases, but in the mode=
rn
> era MODULE_ALIAS() is used to provide that information.
>=20

Thanks for the clarification.

Running an old Red Hat Enterprise Linux ES release 4 (Nahant Update 8)

# cat /etc/modprobe.conf
alias eth0 bnx2x
alias eth1 bnx2x
alias eth2 tg3
alias eth3 tg3

(No /etc/modprobe.d/ directory)

But I can see the alias in the '.dist' file

# grep ipip /etc/modprobe.conf.dist
alias tunl0 ipip

# mv /etc/modprobe.conf.dist /etc/modprobe.conf.dist.old
# ip tunnel add mode ipip
ioctl: No such device

Thanks !


