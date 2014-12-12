From: Cyrille Pitchen <cyrille.pitchen@atmel.com>
Subject: Re: [PATCH v2 1/1] net/macb: add TX multiqueue support for gem
Date: Fri, 12 Dec 2014 10:57:54 +0100
Message-ID: <548ABC22.3080107@atmel.com>
References: <cover.1418291637.git.cyrille.pitchen@atmel.com>	<87a3098203ee6eaa7a60607713a293d3258e2b58.1418291637.git.cyrille.pitchen@atmel.com> <20141211203103.4191887a@free-electrons.com> <063D6719AE5E284EB5DD2968C1650D6D1CA0BA36@AcuExch.aculab.com> <548AAE66.8070501@atmel.com> <063D6719AE5E284EB5DD2968C1650D6D1CA0BA7D@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "nicolas.ferre@atmel.com" <nicolas.ferre@atmel.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"linux-arm-kernel@lists.infradead.org"
	<linux-arm-kernel@lists.infradead.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"soren.brinkmann@xilinx.com" <soren.brinkmann@xilinx.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
To: David Laight <David.Laight@ACULAB.COM>,
	'Thomas Petazzoni' <thomas.petazzoni@free-electrons.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D1CA0BA7D@AcuExch.aculab.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Le 12/12/2014 10:59, David Laight a =E9crit :
> From: Cyrille Pitchen [...
>>> It will probably add a lot of object code and, depending on how oft=
en
>>> the registers are accesses, might have performance impact.
>>>
>>> Having:
>>> #define GEM_ISR(n) (0x400 + (n) << 4)
>>> will save source code.
>>>
>>> 	David
>>>
>>>
>>>
>> So you suggest that we keep the unsigned int fields ISR, IMR, IER, I=
DR, TBQP in
>> the struct macb_queue and initialize them once for all in macb_probe=
() like
>> patch v2 does but only replace the GEM_ISR1 .. GEM_ISR7 defines by G=
EM_ISR(n)
>> in macb.h?
>>
>> This way there would be to test at run time and we can handle the sp=
ecial
>> register mapping of queue0.
>>
>> Is it what you meant?
>=20
> In one word, yes.
>=20
> 	David
>=20
>=20
>=20
OK, so I'm working on v3

Thanks

Cyrille
