From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [2.6.36-rc5] INET?: possible irq lock inversion dependency
Date: Tue, 21 Sep 2010 12:13:31 +0200
Message-ID: <1285064011.2617.238.camel@edumazet-laptop>
References: <201006242053.IAG26562.JHQFFOMSVFtOLO@I-love.SAKURA.ne.jp>
	 <201009072132.FHA93457.MHOJFQOOFLVStF@I-love.SAKURA.ne.jp>
	 <201009210651.o8L6pbkP038129@www262.sakura.ne.jp>
	 <1285055760.2617.27.camel@edumazet-laptop>
	 <201009210910.o8L9Anaf071504@www262.sakura.ne.jp>
	 <1285061757.2617.176.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-fsdevel@vger.kernel.org, netdev@vger.kernel.org
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:53301 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752522Ab0IUKNf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 21 Sep 2010 06:13:35 -0400
In-Reply-To: <1285061757.2617.176.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 21 septembre 2010 =C3=A0 11:36 +0200, Eric Dumazet a =C3=A9cri=
t :
> Le mardi 21 septembre 2010 =C3=A0 18:10 +0900, Tetsuo Handa a =C3=A9c=
rit :
> > Eric Dumazet wrote:
> > > I would say someone calls xs_tcp_state_change() while softirqs ar=
e not
> > > masked.
> > >=20
> > > If its expected, then following patch is needed ?
> >=20
> > After applying your patch, I got the same warning on different plac=
e.
> > I got this when doing "mount 127.0.0.1:/usr/src/ /mnt/".
>=20
> Hmm, but what are the changes in your tree ?
>=20

(Because I dont have these lockdep splats here with 2.6.36-rc5)



