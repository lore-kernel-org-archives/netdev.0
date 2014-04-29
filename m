From: Alexey Charkov <alchark@gmail.com>
Subject: Re: [PATCH] net: via-rhine: fix compiler warning
Date: Tue, 29 Apr 2014 22:09:01 +0400
Message-ID: <CABjd4Yxj12O7pi2kiqjO+YYU_D=Gdx98yNz6XE4tCX=sL2eYxg@mail.gmail.com>
References: <1398792971-10379-1-git-send-email-mq@suse.cz>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Roger Luethi <rl@hellgate.ch>, netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: Jan Moskyto Matejka <mq@suse.cz>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1398792971-10379-1-git-send-email-mq@suse.cz>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2014-04-29 21:36 GMT+04:00 Jan Moskyto Matejka <mq@suse.cz>:
> Fixed different size cast warning:
>
>         drivers/net/ethernet/via/via-rhine.c: In function =E2=80=98rh=
ine_init_one_platform=E2=80=99:
>         drivers/net/ethernet/via/via-rhine.c:1132:13: warning: cast f=
rom pointer to integer of different size [-Wpointer-to-int-cast]
>           revision =3D (u32)match->data;
>                      ^
>
> That code was added in commit 2d283862dc62daead9db0dc89cd0d0351e91f76=
5
> ("net: via-rhine: add OF bus binding").
>
> Signed-off-by: Jan Moskyto Matejka <mq@suse.cz>

Jan, thanks a lot for catching this. Have to admit that I didn't
compile it on 64bit.

Acked-by: Alexey Charkov <alchark@gmail.com>

Looks like the same would apply to e.g. drivers/clk/samsung/clk.c and
maybe some others... Also, a number of drivers cast OF data from (void
*) to (int) or (unsigned int) - isn't this also problematic on 64bit?

Thanks a lot,
Alexey
