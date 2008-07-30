From: =?ISO-8859-1?Q?Fran=E7ois_Valenduc?=
	<francois.valenduc@tvcablenet.be>
Subject: Re: [Bugme-new] [Bug 11144] New: dhcp doesn't work with iwl4965
Date: Wed, 30 Jul 2008 20:04:31 +0200
Message-ID: <4890AD2F.8030502@tvcablenet.be>
References: <4887550B.2070704@tvcablenet.be> <4887555A.30605@trash.net>	 <48875B8C.2090800@trash.net> <20080723.142147.61941255.davem@davemloft.net>	 <48884451.1090703@trash.net>	 <1ba2fa240807240317g15f6ba84h91b513cce75975e9@mail.gmail.com>	 <48885743.8030505@trash.net>	 <1ba2fa240807240435g36daa80at254144afffc39c32@mail.gmail.com>	 (sfid-20080724_133550_701095_354A4111) <1216899926.13587.51.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Tomas Winkler <tomasw@gmail.com>,
	Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>, akpm@linux-foundation.org,
	bugme-daemon@bugzilla.kernel.org, linux-wireless@vger.kernel.org,
	linville@tuxdriver.com, netdev@vger.kernel.org,
	jussi.kivilinna@mbnet.fi
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from agave.telenet-ops.be ([195.130.137.77]:41038 "EHLO
	agave.telenet-ops.be" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751819AbYG3SEg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 30 Jul 2008 14:04:36 -0400
In-Reply-To: <1216899926.13587.51.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Johannes Berg a =E9crit :
> On Thu, 2008-07-24 at 14:35 +0300, Tomas Winkler wrote:
>
>  =20
>>>> Isn't this time to make 802.11 native?
>>>>        =20
>>> You mean by making these things real skb members? I hope you're
>>> not talking about the entire 48 bytes? :)
>>>      =20
>> I mean elevating 802.11 header to 802.3 level. Not doing 802.3 ->
>> 802.11 translation where not needed.
>>    =20
>
>
> We've discussed that over and over and over and over again, and it's =
not
> going to fly since 802.11 throughout assumes that you have a two-addr=
ess
> data service to the upper layers.
>
> Besides, making it 802.11 native doesn't help with the control
> information at all.
>
> johannes
>  =20
It seems the patch you made an available at=20
http://lkml.org/lkml/2008/7/29/153 solves my problem. DHCP works again=20
if I apply it on kernel 2.6.27-rc1.

=46ran=E7ois
