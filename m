From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: is non-inheritance of congestion control algorithm from the
 listen socket a bug or a feature?
Date: Tue, 29 Nov 2011 22:46:15 +0100
Message-ID: <1322603175.2596.31.camel@edumazet-laptop>
References: <4ED53AA1.9090800@hp.com>
	 <1322600212.2596.13.camel@edumazet-laptop>
	 <CAK6E8=djWDn=ZvD0XLxex3vOfsDjCT64k+DwDSNp6+tLbPen2A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Rick Jones <rick.jones2@hp.com>, netdev@vger.kernel.org
To: Yuchung Cheng <ycheng@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ey0-f174.google.com ([209.85.215.174]:44324 "EHLO
	mail-ey0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751020Ab1K2VqU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2011 16:46:20 -0500
Received: by eaak14 with SMTP id k14so3664580eaa.19
        for <netdev@vger.kernel.org>; Tue, 29 Nov 2011 13:46:18 -0800 (PST)
In-Reply-To: <CAK6E8=djWDn=ZvD0XLxex3vOfsDjCT64k+DwDSNp6+tLbPen2A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 29 novembre 2011 =C3=A0 13:20 -0800, Yuchung Cheng a =C3=A9cri=
t :
> I actually think it's a feature :)
>=20
> I find it awkward to set CC on listening socket. And current document
> defines the sysctl well
>=20
> tcp_congestion_control - STRING
>         Set the congestion control algorithm to be used for new
>         connections. The algorithm "reno" is always available, but
>         additional choices may be available based on kernel configura=
tion.
>         Default is set as part of kernel configuration.

This might be a feature, but contradicts most socket options set on
listener and inherited by a child socket on accept()

tcp_congestion_control should be system wide default.

Anyway, "man 7 tcp" doesnt document TCP_CONGESTION, so we are not
supposed to play with it ;)

Oh well...
