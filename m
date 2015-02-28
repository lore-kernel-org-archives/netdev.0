From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net] net: do not use rcu in rtnl_dump_ifinfo()
Date: Fri, 27 Feb 2015 17:05:18 -0800
Message-ID: <1425085518.5130.56.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1425018776-14725-1-git-send-email-xiyou.wangcong@gmail.com>
	 <1425024069.5130.10.camel@edumazet-glaptop2.roam.corp.google.com>
	 <54F09A95.8000507@6wind.com>
	 <1425056838.5130.27.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1425058970.5130.32.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20150228004357.GA28631@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: nicolas.dichtel@6wind.com, Daniel Borkmann <daniel@iogearbox.net>,
	David Miller <davem@davemloft.net>,
	Cong Wang <xiyou.wangcong@gmail.com>, netdev@vger.kernel.org
To: =?UTF-8?Q?J=CE=B5an?= Sacren <sakiwit@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f178.google.com ([209.85.213.178]:35793 "EHLO
	mail-ig0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751111AbbB1BFU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 27 Feb 2015 20:05:20 -0500
Received: by igqa13 with SMTP id a13so4921488igq.0
        for <netdev@vger.kernel.org>; Fri, 27 Feb 2015 17:05:20 -0800 (PST)
In-Reply-To: <20150228004357.GA28631@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2015-02-27 at 17:43 -0700, J=CE=B5an Sacren wrote:

> > Signed-off-by: Eric Dumazet <edumazet@google.com>
> > Fixes: commit 0c7aecd4bde4b7302 ("netns: add rtnl cmd to add and ge=
t peer netns ids")
>=20
> - The word 'commit' is not supposed to be there.
>=20
> - ${SHA1} is supposed to be 12-digit-long.

Right, please David fix this if you care.
