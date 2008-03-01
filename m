From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: Patch: [NET]: Remove CONFIG_PROC_FS depency for pcounter inuse
Date: Sat, 01 Mar 2008 14:45:54 +0100
Message-ID: <47C95E12.609@cosmosbay.com>
References: <47C8E777.5050804@hartkopp.net> <47C91BC6.6050603@cosmosbay.com> <47C93C76.5090905@hartkopp.net> <47C945D7.7050601@cosmosbay.com> <47C950B4.5040703@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Oliver Hartkopp <oliver@hartkopp.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from neuf-infra-smtp-out-sp604007av.neufgp.fr ([84.96.92.120]:40944
	"EHLO neuf-infra-smtp-out-sp604007av.neufgp.fr" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1755382AbYCANqQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 1 Mar 2008 08:46:16 -0500
In-Reply-To: <47C950B4.5040703@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Oliver Hartkopp a =E9crit :
> Eric Dumazet wrote:
>> Oliver Hartkopp a =E9crit :
>>> It's not about the counter implementation but the integration/usage=
=20
>>> in the networking subsystem.
>>>
>>> Or does your mentioned patch mean, that the added functions in=20
>>> proto_[un|]register() will also be reverted?
>>>
>>
>> A patch will make inet use percpu_counter instead of pcounter.
>>
>> Then a zap patch will delete lib/pcounter.c & include/linux/pcounter=
=2Eh
>>
>> I dont understand why you say CONFIG_PROC_FS is *forced*.
>> I can build a kernel with CONFIG_PROC_FS=3Dn, with working INET.
> Right. With enabled CONFIG_EMBEDDED you might have CONFIG_INET with=20
> CONFIG_PROC_FS=3Dn.
>=20
> But this is not the thing, i wanted to point out.
>=20
> My major concern was, that "whatever-per-cpu-counters" are=20
> allocated/initialized in "proto_register()" for *every* network proto=
col=20
> but *only* IPv[4|6] is using these counters (when CONFIG_PROC_FS is s=
et).
>=20
> I just wanted to point out the situation for network protocols that d=
o=20
> not need any inuse counters. In the current implementation the pcount=
ers=20
> are allocated for every networking protocol in proto_register() which=
=20
> does not look optimized to me.
>=20
> Will this change with your patch that uses percpu_counter instead of=20
> pcounter??
>=20

Yes, everything will be cleaned by me.

We dont need to *optimize* something that will die very soon.

Thank you
