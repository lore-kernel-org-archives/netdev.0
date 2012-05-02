From: Sasha Levin <levinsasha928@gmail.com>
Subject: Re: [PATCH] net: l2tp: unlock socket lock before returning from l2tp_ip_sendmsg
Date: Wed, 2 May 2012 15:49:41 +0200
Message-ID: <CA+1xoqfVQfPseoSuBLY99nx_BuXpoGD4X6_xKk9_BoG0Mo__jw@mail.gmail.com>
References: <1335964237-1139-1-git-send-email-levinsasha928@gmail.com> <1335965318.22133.568.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, jchapman@katalix.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, davej@redhat.com
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1335965318.22133.568.camel@edumazet-glaptop>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, May 2, 2012 at 3:28 PM, Eric Dumazet <eric.dumazet@gmail.com> w=
rote:
> Good catch, but please use existing code style in this function.
>
> rc =3D -EDESTADDRREQ;
> if (sk->sk_state !=3D TCP_ESTABLISHED)
> =A0 =A0 =A0 =A0goto out;
>
> Also, please add in your commit message bug origin to ease stable tea=
m
> work (not counting reviewers work)
>
> Bug added in commit 2f16270f41e1 (l2tp: Fix locking in l2tp_ip.c)
>
> Really, given the amount of patches you already sent, you should alre=
ady
> know that.
>
> Thanks
>
>

Understood. I'll resend.
