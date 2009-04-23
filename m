From: Salatiel Filho <salatiel.filho@gmail.com>
Subject: Re: IMQ bug: kernel reboot immediately
Date: Thu, 23 Apr 2009 09:37:03 -0300
Message-ID: <beb91d720904230537s7f61c441g5af4a3acc1a0c2aa@mail.gmail.com>
References: <20090423084323.GA5696@ff.dom.local> <49F040E8.80402@trash.net>
	<alpine.LSU.2.00.0904231223050.18687@fbirervta.pbzchgretzou.qr>
	<49F042E7.7060900@trash.net> <beb91d720904230412j4dea4034o61f2d0682ff76d1a@mail.gmail.com>
	<49F04F6B.7010709@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jan Engelhardt <jengelh@medozas.de>,
	Jarek Poplawski <jarkao2@gmail.com>,
	"Y. D." <duyuyang@gmail.com>, netdev <netdev@vger.kernel.org>,
	netfilter-devel <netfilter-devel@vger.kernel.org>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <49F04F6B.7010709@trash.net>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Apr 23, 2009 at 08:22, Patrick McHardy <kaber@trash.net> wrote:
> Salatiel Filho wrote:
>>
>> On Thu, Apr 23, 2009 at 07:28, Patrick McHardy <kaber@trash.net> wro=
te:
>>>
>>> I'm aware of those claims, but not of the details. If this is true,
>>> people should raise those issues and help resolve them. I wouldn't
>>> hold my breath waiting for IMQ to get fixed.
>>>
>>
>> I would love to see a way to change where IFB hooks [if "hook" is th=
e
>> right term ], till now i dont think i am able to hook it after nat i=
n
>> prerouting and before nat in postrouting. Is there a way to do this =
?
>> What i basically do with IMQ is:
>>
>>
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 eth0 [192.168.0.0/24=
]
>> ppp0 =A0 <----> =A0 =A0 =A0 eth1 [192.168.1.0/24]
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 eth2 [192.168.2.0/24=
]
>>
>> Using imq i can shape upload on ppp0 [postrouting] while still havin=
g
>> the internal private ips from the hosts, and i can shape download in
>> ppp0 [prerouting] after get the correct nat'ed addresses.
>>
>> Is there a way to achieve this in IFB ? in a simple way ... :)
>
> Currently not, the conntrack association is done at a later point.
> We could add a classifier or TC action that performs the lookup
> during ingress classification.
>
> Alternatively classifiers using conntrack information (like cls_flow)
> could perform the lookup directly, but that would probably get a bit
> ugly since some validation needs to be performed previously and it
> would add a module dependency on conntrack.
>
>
Using this actions would make  sfq hashing by dest ip or source ip
work just like it works in imq ?


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
