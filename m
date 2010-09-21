From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [2.6.36-rc5] INET?: possible irq lock inversion dependency
Date: Tue, 21 Sep 2010 11:35:57 +0200
Message-ID: <1285061757.2617.176.camel@edumazet-laptop>
References: <201006242053.IAG26562.JHQFFOMSVFtOLO@I-love.SAKURA.ne.jp>
	 <201009072132.FHA93457.MHOJFQOOFLVStF@I-love.SAKURA.ne.jp>
	 <201009210651.o8L6pbkP038129@www262.sakura.ne.jp>
	 <1285055760.2617.27.camel@edumazet-laptop>
	 <201009210910.o8L9Anaf071504@www262.sakura.ne.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-fsdevel@vger.kernel.org, netdev@vger.kernel.org
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <201009210910.o8L9Anaf071504@www262.sakura.ne.jp>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le mardi 21 septembre 2010 =C3=A0 18:10 +0900, Tetsuo Handa a =C3=A9cri=
t :
> Eric Dumazet wrote:
> > I would say someone calls xs_tcp_state_change() while softirqs are =
not
> > masked.
> >=20
> > If its expected, then following patch is needed ?
>=20
> After applying your patch, I got the same warning on different place.
> I got this when doing "mount 127.0.0.1:/usr/src/ /mnt/".

Hmm, but what are the changes in your tree ?


--
To unsubscribe from this list: send the line "unsubscribe linux-fsdevel=
" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
