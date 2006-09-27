From: Ismail Donmez <ismail@pardus.org.tr>
Subject: Re: tc related lockdep warning.
Date: Wed, 27 Sep 2006 17:41:08 +0300
Message-ID: <200609271741.09375.ismail@pardus.org.tr>
References: <20060925124352.GA1592@ff.dom.local> <20060926212034.GA3134@redhat.com> <451A4EEE.6080004@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Dave Jones <davej@redhat.com>, hadi@cyberus.ca,
	Jarek Poplawski <jarkao2@o2.pl>, netdev@vger.kernel.org,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.uludag.org.tr ([193.140.100.220]:53484 "EHLO uludag.org.tr")
	by vger.kernel.org with ESMTP id S932359AbWI0Okt convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Sep 2006 10:40:49 -0400
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <451A4EEE.6080004@trash.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

27 Eyl 2006 =C3=87ar 13:14 tarihinde =C5=9Funlar=C4=B1 yazm=C4=B1=C5=9F=
t=C4=B1n=C4=B1z:
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
>
> I can't reproduce this, could you send me your tc script please?
> Did you do anything to trigger this?

Using sabishape[1] with latest linux-2.6 git tree I can reproduce this.=
 Just=20
running sabishape -i eth1 -u 50 -d 240 freezes whole box.

[1] http://www.sabi.co.uk/Proj/Small/sabishape-2.1.tar.gz

Regards,
ismail

--=20
They that can give up essential liberty to obtain a little temporary sa=
fety=20
deserve neither liberty nor safety.
-- Benjamin Franklin
