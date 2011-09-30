From: Nobuhiro Iwamatsu <nobuhiro.iwamatsu.yj@renesas.com>
Subject: Re: [PATCH] net: sh_eth: fix build failure
Date: Sat, 1 Oct 2011 04:36:53 +0900
Message-ID: <CABMQnVKLL8fA9sZCNE4gPSo3z8fNXV7tv=LD9MLS1Tr7y48hAA@mail.gmail.com>
References: <4E8534A9.3050002@renesas.com> <CABMQnVLRO1q=Oi7CWE=CJqYcUBD6s+z1JTWrO8W1wVmFwuA45w@mail.gmail.com>
 <4E857506.5030501@renesas.com> <20110930.035449.1012299223616580574.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: yoshihiro.shimoda.uh@renesas.com, sfr@canb.auug.org.au,
	netdev@vger.kernel.org, linux-sh@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <20110930.035449.1012299223616580574.davem@davemloft.net>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I see.
Thanks you.

Nobuhiro

2011/9/30 David Miller <davem@davemloft.net>:
> From: Yoshihiro Shimoda <yoshihiro.shimoda.uh@renesas.com>
> Date: Fri, 30 Sep 2011 16:51:34 +0900
>
>> 2011/09/30 15:55, Nobuhiro Iwamatsu wrote:
>>> 2011/9/30 Yoshihiro Shimoda <yoshihiro.shimoda.uh@renesas.com>:
>> < snip >
>>>> +#include <linux/kernel.h>
>>>> +#include <linux/spinlock.h>
>>> These are not required.
>>
>> The Documentation/SubmitChecklist says the following:
>>
>> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D
>> 1: If you use a facility then #include the file that defines/declare=
s
>> =A0 =A0that facility. =A0Don't depend on other header files pulling =
in ones
>> =A0 =A0that you use.
>> =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D
>>
>> The sh_eth driver uses spinlock functions and some macros of kernel.=
h.
>> So, I think that I have to write their "#include" in the driver.
>
> Agreed.
> --
> To unsubscribe from this list: send the line "unsubscribe linux-sh" i=
n
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>



--=20
Nobuhiro Iwamatsu
