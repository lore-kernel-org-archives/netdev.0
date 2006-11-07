From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: ZONE_NORMAL memory exhausted by 4000 TCP sockets
Date: Tue, 07 Nov 2006 06:53:36 +0100
Message-ID: <45501F60.4070606@cosmosbay.com>
References: <f55850a70611052207j384e1d3flaf40bb9dd74df7c5@mail.gmail.com>
 <200611061022.57840.dada1@cosmosbay.com>
 <f55850a70611060146o1b2adcabq8c1313f6711f3f4e@mail.gmail.com>
 <200611061433.50912.dada1@cosmosbay.com>
 <f55850a70611061848g5f316399oe877a38705e7f99b@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org,
	Linux Netdev List <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sp604005mt.neufgp.fr ([84.96.92.11]:4844 "EHLO smtp.Neuf.fr")
	by vger.kernel.org with ESMTP id S1754049AbWKGFxc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Nov 2006 00:53:32 -0500
In-reply-to: <f55850a70611061848g5f316399oe877a38705e7f99b@mail.gmail.com>
To: Zhao Xiaoming <xiaoming.nj@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Zhao Xiaoming a =E9crit :
> On 11/6/06, Eric Dumazet <dada1@cosmosbay.com> wrote:
>> In fact, your kernel has CONFIG_4KSTACKS, kernel thread stacks use 4=
K=20
>> instead
>> of 8K.
>>
>> If you want to increase LOWMEM, (and keep 32bits kernel), you can ch=
ose a
>> 2G/2G user/kernel split, instead of the 3G/1G default split.
>> (see config : CONFIG_VMSPLIT_2G)
>>
>> Eric

> Thank you for your advice. I know increase LOMEM could be help, but
> now my concern is why I lose my 500M bytes memory after excluding all
> known memory cost.

Unfortunatly you dont provide very much details.
AFAIK you didnt even gave whcih version of linux you run, which program=
s you=20
run...
You keep answering where you 'lost' your mem, it's quite buging.
Maybe some Oracles on this list will see the light for you, before exch=
anging=20
100 mails with you ?

