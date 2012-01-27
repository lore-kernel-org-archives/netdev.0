From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Default TCP Options creating problems
Date: Fri, 27 Jan 2012 15:49:34 +0100
Message-ID: <1327675774.2220.13.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
References: <4F22B17A.2080809@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Nanda Kumar <heramba85@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-we0-f174.google.com ([74.125.82.174]:39290 "EHLO
	mail-we0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751601Ab2A0Oti (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Jan 2012 09:49:38 -0500
Received: by werb13 with SMTP id b13so1289123wer.19
        for <netdev@vger.kernel.org>; Fri, 27 Jan 2012 06:49:37 -0800 (PST)
In-Reply-To: <4F22B17A.2080809@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 27 janvier 2012 =C3=A0 19:45 +0530, Nanda Kumar a =C3=A9cri=
t :
> Hi,
>=20
> I am using Ubuntu 11.10 and unable to connect to my ISP login server.
> The same is working under windows. Under linux, ISP server does not
> respond TCP SYN packet even. I did a comparison of packet capture of
> windows and linux and found, linux include TCP options by default.
> After manually disabling TCP Timestamp via sysctl, the login is
> happening fine.
>=20

>=20
> Is there any reason why TCP option is enabled by default? The same
> problem was happening under OpenSUSE 12.1 x86_64 also. My friend
> informed me that his android mobile is also unable to connect to ISP
> login server.

I am very sorry, but you should complain to your ISP, 20 years after RF=
C
1323, it should support it.

TCP options are ... options, and as such should not be denied by a
conformant TCP stack.
