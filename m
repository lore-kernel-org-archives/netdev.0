From: Changli Gao <xiaosuo@gmail.com>
Subject: Re: [PATCH 2/2] act_mirred: optimization
Date: Mon, 16 Nov 2009 21:05:28 +0800
Message-ID: <412e6f7f0911160505x10da9a92j694669db9d030da1@mail.gmail.com>
References: <412e6f7f0911160153g31d5eado7c5569d9e95f7d01@mail.gmail.com>
	 <20091116.024839.257258321.davem@davemloft.net>
	 <20091116.025859.78494103.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: hadi@cyberus.ca, shemminger@vyatta.com, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f171.google.com ([209.85.222.171]:49910 "EHLO
	mail-pz0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751765AbZKPNFW convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Nov 2009 08:05:22 -0500
Received: by pzk1 with SMTP id 1so2763974pzk.33
        for <netdev@vger.kernel.org>; Mon, 16 Nov 2009 05:05:28 -0800 (PST)
In-Reply-To: <20091116.025859.78494103.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 16, 2009 at 6:58 PM, David Miller <davem@davemloft.net> wro=
te:
> From: David Miller <davem@davemloft.net>
> Date: Mon, 16 Nov 2009 02:48:39 -0800 (PST)
>
>> From: Changli Gao <xiaosuo@gmail.com>
>> Date: Mon, 16 Nov 2009 17:53:29 +0800
>>
>>> act_mirred: optimization.
>>>
>>> move checking if eaction is valid in tcf_mirred_init()
>>>
>>> Signed-off-by: Changli Gao <xiaosuo@gmail.com>
>>> Signed-off-by: Jamal Hadi Salim <hadi@cyberus.ca>
>>
>> Also applied, thank you.
>
> Nevermind, you're NOT TESTING the patches you are posting:
>
> net/sched/act_mirred.c: In function =E2=80=98tcf_mirred=E2=80=99:
> net/sched/act_mirred.c:168: error: label =E2=80=98out=E2=80=99 used b=
ut not defined
> net/sched/act_mirred.c:158: warning: unused variable =E2=80=98err=E2=80=
=99
> net/sched/act_mirred.c:158: warning: unused variable =E2=80=98retval=E2=
=80=99
> make[2]: *** [net/sched/act_mirred.o] Error 1
> make[1]: *** [net/sched] Error 2
> make[1]: *** Waiting for unfinished jobs....
>
> I'm thus reverting both changes.
>
> Don't submit changes which are untested, it wastes my time.
>

I am sorry about that. But I did test it before submitting these two,
and I am just wondering if they are applied without any error. Would
you post the file after being patched? I think it will be helpful to
finger out the real problem.

BTW: since my email client thunderbird was broken, I used google
webmail(with ViewSourceWith addon) to submit these two patches.

--=20
Regards=EF=BC=8C
Changli Gao(xiaosuo@gmail.com)
