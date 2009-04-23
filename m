From: Salatiel Filho <salatiel.filho@gmail.com>
Subject: Re: IMQ bug: kernel reboot immediately
Date: Thu, 23 Apr 2009 08:12:31 -0300
Message-ID: <beb91d720904230412j4dea4034o61f2d0682ff76d1a@mail.gmail.com>
References: <20090423084323.GA5696@ff.dom.local> <49F040E8.80402@trash.net>
	<alpine.LSU.2.00.0904231223050.18687@fbirervta.pbzchgretzou.qr>
	<49F042E7.7060900@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jan Engelhardt <jengelh@medozas.de>,
	Jarek Poplawski <jarkao2@gmail.com>,
	"Y. D." <duyuyang@gmail.com>, netdev <netdev@vger.kernel.org>,
	netfilter-devel <netfilter-devel@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <49F042E7.7060900@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Apr 23, 2009 at 07:28, Patrick McHardy <kaber@trash.net> wrote:
> Jan Engelhardt wrote:
>>
>> On Thursday 2009-04-23 12:20, Patrick McHardy wrote:
>>
>>>>> Is IMQ still maintained? I am using IMQ to shape ingress traffic.
>>>>> But the application is a streaming server (VLC). However, the ker=
nel
>>>>> reboots immediately as quick as can hardly been seen what is
>>>>> wrong with it.
>>>>>
>>>>> Any help with this kinda problem?
>>>>
>>>> IMQ isn't a part of kernel/netfilter, so you should try at its own
>>>> site/mailing list.
>>>
>>> I'd rather suggest to get rid of it and use ifb, AFAIK there hasn't
>>> been a single version in all those years that didn't cause this kin=
d
>>> of problems.
>>
>> I'd rather point out that ifb does not seem to be able to do all of =
what
>> IMQ can, up to the point where it is believed in the public that ifb=
 is
>> practically useless.
>
> I'm aware of those claims, but not of the details. If this is true,
> people should raise those issues and help resolve them. I wouldn't
> hold my breath waiting for IMQ to get fixed.
>

I would love to see a way to change where IFB hooks [if "hook" is the
right term ], till now i dont think i am able to hook it after nat in
prerouting and before nat in postrouting. Is there a way to do this ?
What i basically do with IMQ is:


                         eth0 [192.168.0.0/24]
ppp0   <---->       eth1 [192.168.1.0/24]
                         eth2 [192.168.2.0/24]

Using imq i can shape upload on ppp0 [postrouting] while still having
the internal private ips from the hosts, and i can shape download in
ppp0 [prerouting] after get the correct nat'ed addresses.

Is there a way to achieve this in IFB ? in a simple way ... :)




> --
> To unsubscribe from this list: send the line "unsubscribe netfilter-d=
evel"
> in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>



--=20
[]'s
Salatiel

"O maior prazer do inteligente =E9 bancar o  idiota
   diante de um  idiota que banca o inteligente".
--
To unsubscribe from this list: send the line "unsubscribe netfilter-dev=
el" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
