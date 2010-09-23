From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] net: fix a lockdep splat
Date: Thu, 23 Sep 2010 07:42:57 +0200
Message-ID: <1285220577.2380.72.camel@edumazet-laptop>
References: <201006242053.IAG26562.JHQFFOMSVFtOLO@I-love.SAKURA.ne.jp>
	 <201009072132.FHA93457.MHOJFQOOFLVStF@I-love.SAKURA.ne.jp>
	 <201009210651.o8L6pbkP038129@www262.sakura.ne.jp>
	 <1285055760.2617.27.camel@edumazet-laptop>
	 <201009210910.o8L9Anaf071504@www262.sakura.ne.jp>
	 <1285061757.2617.176.camel@edumazet-laptop>
	 <1285064011.2617.238.camel@edumazet-laptop>
	 <201009220714.o8M7Ebps067361@www262.sakura.ne.jp>
	 <1285144306.2639.90.camel@edumazet-laptop>
	 <1285144471.2639.96.camel@edumazet-laptop>
	 <1285144681.2639.102.camel@edumazet-laptop>
	 <201009220858.o8M8w8s3094017@www262.sakura.ne.jp>
	 <1285176935.2639.453.camel@edumazet-laptop>
	 <1285184088.2380.18.camel@edumazet-laptop>  <4C9A7F7F.5010507@gmail.com>
	 <1285195419.2380.39.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>,
	David Miller <davem@davemloft.net>,
	linux-fsdevel@vger.kernel.org, netdev@vger.kernel.org
To: Jarek Poplawski <jarkao2@gmail.com>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <1285195419.2380.39.camel@edumazet-laptop>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le jeudi 23 septembre 2010 =C3=A0 00:43 +0200, Eric Dumazet a =C3=A9cri=
t :

>=20
> [PATCH v2] net: fix a lockdep splat
>=20
=2E..
> lockdep is not happy with this, as reported by Tetsuo Handa
>=20
> It seems only way to deal with this is to use read_lock_bh(callbacklo=
ck)
> everywhere.
>=20
> Thanks to Jarek for pointing a bug in my first attempt and suggesting
> this solution.
>=20
> Reported-by: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> CC: Jarek Poplawski <jarkao2@gmail.com>

Tested-by: Eric Dumazet <eric.dumazet@gmail.com>

I tested it on my machine and could not reproduce the lockdep splat.



--
To unsubscribe from this list: send the line "unsubscribe linux-fsdevel=
" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
