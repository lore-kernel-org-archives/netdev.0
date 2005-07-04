From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: [TG3]: About hw coalescing infrastructure.
Date: Tue, 05 Jul 2005 00:31:55 +0200
Message-ID: <42C9B8DB.7020403@cosmosbay.com>
References: <42B982D4.9040704@cosmosbay.com>	<1119467012.5325.15.camel@rh4>	<42C9A884.1030906@cosmosbay.com> <20050704.142604.18592223.davem@davemloft.net> <42C9AC97.1020902@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: quoted-printable
Cc: "David S. Miller" <davem@davemloft.net>, mchan@broadcom.com,
        netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Eric Dumazet <dada1@cosmosbay.com>
In-Reply-To: <42C9AC97.1020902@cosmosbay.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Eric Dumazet a =E9crit :
> David S. Miller a =E9crit :
>=20
>> From: Eric Dumazet <dada1@cosmosbay.com>
>> Date: Mon, 04 Jul 2005 23:22:12 +0200
>>
>>
>>> But it seems something is wrong because when network load becomes=20
>>> high I get :
>>>
>>> Jul  4 23:01:19 dada1 kernel: NETDEV WATCHDOG: eth0: transmit timed o=
ut
>>> Jul  4 23:01:19 dada1 kernel: tg3: eth0: transmit timed out, resettin=
g
>>> Jul  4 23:01:24 dada1 kernel: NETDEV WATCHDOG: eth0: transmit timed o=
ut
>>> Jul  4 23:01:24 dada1 kernel: tg3: eth0: transmit timed out, resettin=
g
>>> Jul  4 23:01:29 dada1 kernel: NETDEV WATCHDOG: eth0: transmit timed o=
ut
>>
>>
>>
>> Does this happen without changing the coalescing settings
>> at all?
>>
>>
> Not easy to answer because I have to rebuild a kernel and reboot. Will=20
> do that shortly.
>=20
>=20
>=20

Oops, I forgot to tell you I applied the patch  : [TG3]: Eliminate all hw=
 IRQ handler spinlocks.
(Date: Fri, 03 Jun 2005 12:25:58 -0700 (PDT))

Maybe I should revert to stock 2.6.12 tg3 driver ?

Eric
