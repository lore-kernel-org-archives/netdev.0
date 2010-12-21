From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH net-2.6] net_sched: always clone skbs
Date: Tue, 21 Dec 2010 08:21:41 +0800
Message-ID: <AANLkTi=uhQ8R4i+ZqjBZuFb6pduHzDEZT5_o4VA7jhgC@mail.gmail.com>
References: <1292855730-19265-1-git-send-email-xiaosuo@gmail.com>
 <20101220232020.GB2052@del.dom.local> <1292887689.2627.150.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jarek Poplawski <jarkao2@gmail.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	Jamal Hadi Salim <hadi@cyberus.ca>,
	Pawel Staszewski <pstaszewski@itcare.pl>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f43.google.com ([209.85.161.43]:45617 "EHLO
	mail-fx0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757676Ab0LUAWC convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 20 Dec 2010 19:22:02 -0500
Received: by fxm18 with SMTP id 18so3735660fxm.2
        for <netdev@vger.kernel.org>; Mon, 20 Dec 2010 16:22:01 -0800 (PST)
In-Reply-To: <1292887689.2627.150.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 21, 2010 at 7:28 AM, Eric Dumazet <eric.dumazet@gmail.com> =
wrote:
>
> Indeed, commit number is wrong. It was :
>
> commit 210d6de78c5d7c785fc532556cea340e517955e1
> Author: Changli Gao <xiaosuo@gmail.com>
> Date: =A0 Thu Jun 24 16:25:12 2010 +0000
>
> =A0 =A0act_mirred: don't clone skb when skb isn't shared
>
> It triggers now because GRO might be default to on now.
>
> commit 6a08d194ee40806e0ccd5f36ed768e64cbfc979f
> e1000: use GRO for receive
>
> (or other various GRO patches)
>
>

Oops. It is all my fault. Sorry. What can I do to fix this after David
has applied it and pushed it out?


--=20
Regards,
Changli Gao(xiaosuo@gmail.com)
