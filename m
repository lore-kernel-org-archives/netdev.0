From: =?UTF-8?Q?Am=C3=A9rico_Wang?= <xiyou.wangcong@gmail.com>
Subject: Re: [patch] netpoll: call dev_put() on error in netpoll_setup()
Date: Sun, 12 Jun 2011 13:48:51 +0800
Message-ID: <BANLkTin9d0kEzOcNGt-x49caagLz5uRDEg@mail.gmail.com>
References: <20110611155047.GA3583@shale.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: WANG Cong <amwang@redhat.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Neil Horman <nhorman@tuxdriver.com>,
	"David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	"open list:NETWORKING [GENERAL]" <netdev@vger.kernel.org>,
	kernel-janitors@vger.kernel.org
To: Dan Carpenter <error27@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:38705 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751180Ab1FLFsw convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 12 Jun 2011 01:48:52 -0400
In-Reply-To: <20110611155047.GA3583@shale.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, Jun 11, 2011 at 11:50 PM, Dan Carpenter <error27@gmail.com> wro=
te:
> There is a dev_put(ndev) missing on an error path. =C2=A0This was
> introduced in 0c1ad04aecb "netpoll: prevent netpoll setup on slave
> devices".
>
> Signed-off-by: Dan Carpenter <error27@gmail.com>
> ---
> This is a static checker bug, and it's possible I've misunderstood
> something.

Oops! My bad... you don't miss anything.

Thanks a lot for fixing it!
