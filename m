From: =?ISO-8859-1?Q?Nicolas_de_Peslo=FCan?=
	<nicolas.2p.debian@gmail.com>
Subject: Re: [PATCH net-2.6] bonding: drop frames received with master's	source
 MAC
Date: Wed, 02 Mar 2011 21:30:27 +0100
Message-ID: <4D6EA8E3.5020708@gmail.com>
References: <4D683653.4050409@gmail.com> <20110228163255.GJ11864@gospo.rdu.redhat.com> <4D6C1764.1040008@gmail.com> <20110301023525.GK11864@gospo.rdu.redhat.com> <9882.1298958366@death> <20110301181624.GM11864@gospo.rdu.redhat.com> <4D6D658C.90300@gmail.com> <20893.1299018331@death> <4D6D7C66.6050205@gmail.com> <AANLkTi=QTDNBf7Jskj55NP64Os8kgEs1WMpFGHMo+K3B@mail.gmail.com> <20110302123004.GA21002@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Jay Vosburgh <fubar@us.ibm.com>,
	Andy Gospodarek <andy@greyhouse.net>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Jiri Pirko <jpirko@redhat.com>
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:34015 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755400Ab1CBUab (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Mar 2011 15:30:31 -0500
Received: by wyg36 with SMTP id 36so396990wyg.19
        for <netdev@vger.kernel.org>; Wed, 02 Mar 2011 12:30:30 -0800 (PST)
In-Reply-To: <20110302123004.GA21002@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le 02/03/2011 13:30, Herbert Xu a =E9crit :
> On Wed, Mar 02, 2011 at 11:10:07AM +0100, Nicolas de Peslo=FCan wrote=
:
>>
>> If one decide to configure two interfaces with the same MAC and conn=
ect them
>> to the same LAN, then we get the exact same situation. Having eth0 a=
nd eth1
>> share a single MAC and a single IP address, connected to a switch in
>> Etherchannel mode is a perfectly valid setup, while suboptimal. And =
if the
>> Etherchannel mode happens to be improperly configured, we end up wit=
h the
>> same problem as reported by Andy.
>
> Right.  There's also the case where you have other MAC addresses
> sitting behind the bonding device, e.g., virtualisation.  So basing
> it purely on the bonding device's MAC address is probably not worth
> the trouble.
>
> Cheers,

I'm afraid we miss a general way to fix the general problem. We probabl=
y need to handle the problem=20
at every places that can suffer from the multicast loop, until we find =
a general fix, if ever.

	Nicolas.

