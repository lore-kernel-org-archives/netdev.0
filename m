From: Luca Tettamanti <kronos.it-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [Bug #13838] kernel BUG at include/net/netns/generic.h:41!
Date: Tue, 28 Jul 2009 10:30:46 +0200
Message-ID: <68676e00907280130tbbf5672x83182641b0c977b3@mail.gmail.com>
References: <Jya1GruKQpD.A.16.2GObKB@chimera>
	 <3zAHs5O6maO.A.B5B.IHObKB@chimera>
	 <2375c9f90907262229t2def934emb9340c31d3efdc21@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Rafael J. Wysocki" <rjw-KKrjLPT3xs0@public.gmane.org>,
	Linux Kernel Mailing List <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Kernel Testers List <kernel-testers-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org,
	Alexey Dobriyan <adobriyan-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: =?UTF-8?Q?Am=C3=A9rico_Wang?= <xiyou.wangcong-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <2375c9f90907262229t2def934emb9340c31d3efdc21-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: kernel-testers-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Jul 27, 2009 at 7:29 AM, Am=C3=A9rico Wang<xiyou.wangcong@gmail=
=2Ecom> wrote:
> On Mon, Jul 27, 2009 at 4:28 AM, Rafael J. Wysocki<rjw-KKrjLPT3xs0@public.gmane.org> wrote=
:
>> This message has been generated automatically as a part of a report
>> of recent regressions.
>>
>> The following bug entry is on the current list of known regressions
>> from 2.6.30. =C2=A0Please verify if it still should be listed and le=
t me know
>> (either way).
>>
>>
>> Bug-Entry =C2=A0 =C2=A0 =C2=A0 : http://bugzilla.kernel.org/show_bug=
=2Ecgi?id=3D13838
>> Subject =C2=A0 =C2=A0 =C2=A0 =C2=A0 : kernel BUG at include/net/netn=
s/generic.h:41!
>> Submitter =C2=A0 =C2=A0 =C2=A0 : Luca Tettamanti <kronos.it-Re5JQEeQqe8@public.gmane.org=
m>
>> Date =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0: 2009-07-20 15:27 (7 =
days old)
>> References =C2=A0 =C2=A0 =C2=A0: http://lkml.org/lkml/2009/7/20/105
>
> Hmm, it looks like that 'pfkey_net_id' is still zero after ipsec_pfke=
y_init()...
>
> Add Herbert and net-dev into Cc.
>
> Luca, would you mind to provide your .config and the steps to reprodu=
ce this?

I cannot reproduce it anymore with the current git kernel. The BUG was
triggered by racoon at startup.
Should I go back to an older kernel to investigate or can we consider
it "fixed"?

Luca
