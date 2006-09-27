From: Ismail Donmez <ismail@pardus.org.tr>
Subject: Re: tc related lockdep warning.
Date: Wed, 27 Sep 2006 20:26:04 +0300
Message-ID: <200609272026.04934.ismail@pardus.org.tr>
References: <20060925124352.GA1592@ff.dom.local> <20060926212034.GA3134@redhat.com> <451A6968.2090607@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Dave Jones <davej@redhat.com>, hadi@cyberus.ca,
	Jarek Poplawski <jarkao2@o2.pl>, netdev@vger.kernel.org,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.uludag.org.tr ([193.140.100.220]:34027 "EHLO uludag.org.tr")
	by vger.kernel.org with ESMTP id S1030332AbWI0R0A convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Sep 2006 13:26:00 -0400
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <451A6968.2090607@trash.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

27 Eyl 2006 =C3=87ar 15:07 tarihinde, Patrick McHardy =C5=9Funlar=C4=B1=
 yazm=C4=B1=C5=9Ft=C4=B1:=20
> Dave Jones wrote:
> > With this patch, I get no lockdep warnings, but the machine locks u=
p
> > completely. I hooked up a serial console, and found this..
> >
> >
> > u32 classifier
> >     Performance counters on
> >     input device check on
> >     Actions configured
> > BUG: warning at net/sched/sch_htb.c:395/htb_safe_rb_erase()
> >
> > Call Trace:
> >  [<ffffffff8026f79b>] show_trace+0xae/0x336
> >  [<ffffffff8026fa38>] dump_stack+0x15/0x17
> >  [<ffffffff8860a171>] :sch_htb:htb_safe_rb_erase+0x3b/0x55
>
> I found the reason for this, it was an unrelated bug. I've attached
> the latest version of the locking fixes and the fix for the HTB bug.
> Can you please try again?

This patch (01.diff) fixed the hard lockup for me, thanks.

/ismail

--=20
They that can give up essential liberty to obtain a little temporary sa=
fety=20
deserve neither liberty nor safety.
-- Benjamin Franklin
