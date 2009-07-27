From: =?UTF-8?Q?Am=C3=A9rico_Wang?= <xiyou.wangcong@gmail.com>
Subject: Re: [Bug #13838] kernel BUG at include/net/netns/generic.h:41!
Date: Mon, 27 Jul 2009 13:29:50 +0800
Message-ID: <2375c9f90907262229t2def934emb9340c31d3efdc21@mail.gmail.com>
References: <Jya1GruKQpD.A.16.2GObKB@chimera>
	 <3zAHs5O6maO.A.B5B.IHObKB@chimera>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Kernel Testers List <kernel-testers@vger.kernel.org>,
	Luca Tettamanti <kronos.it@gmail.com>, netdev@vger.kernel.org,
	herbert@gondor.apana.org.au
To: "Rafael J. Wysocki" <rjw@sisk.pl>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752519AbZG0F3w@vger.kernel.org>
In-Reply-To: <3zAHs5O6maO.A.B5B.IHObKB@chimera>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Jul 27, 2009 at 4:28 AM, Rafael J. Wysocki<rjw@sisk.pl> wrote:
> This message has been generated automatically as a part of a report
> of recent regressions.
>
> The following bug entry is on the current list of known regressions
> from 2.6.30. =C2=A0Please verify if it still should be listed and let=
 me know
> (either way).
>
>
> Bug-Entry =C2=A0 =C2=A0 =C2=A0 : http://bugzilla.kernel.org/show_bug.=
cgi?id=3D13838
> Subject =C2=A0 =C2=A0 =C2=A0 =C2=A0 : kernel BUG at include/net/netns=
/generic.h:41!
> Submitter =C2=A0 =C2=A0 =C2=A0 : Luca Tettamanti <kronos.it@gmail.com=
>
> Date =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0: 2009-07-20 15:27 (7 d=
ays old)
> References =C2=A0 =C2=A0 =C2=A0: http://lkml.org/lkml/2009/7/20/105

Hmm, it looks like that 'pfkey_net_id' is still zero after ipsec_pfkey_=
init()...

Add Herbert and net-dev into Cc.

Luca, would you mind to provide your .config and the steps to reproduce=
 this?

Thanks.
