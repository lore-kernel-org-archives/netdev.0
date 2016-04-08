From: Daniel Borkmann <daniel@iogearbox.net>
Subject: Re: [PATCH net-next] ipv6, token: allow for clearing the current
 device token
Date: Fri, 08 Apr 2016 19:13:02 +0200
Message-ID: <5707E69E.1090200@iogearbox.net>
References: <307b4d32099f606d0fbe0ce9fecd3a039b796361.1460123261.git.daniel@iogearbox.net> <878u0otc96.fsf@nemi.mork.no> <1460126038.1452331.572938089.68D8127C@webmail.messagingengine.com> <874mbct95a.fsf@nemi.mork.no> <5707CFF6.6090707@stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, robbat2@gentoo.org, netdev@vger.kernel.org
To: Hannes Frederic Sowa <hannes@stressinduktion.org>,
	=?UTF-8?B?QmrDuHJu?= =?UTF-8?B?IE1vcms=?= <bjorn@mork.no>
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:33365 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758325AbcDHRNQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Apr 2016 13:13:16 -0400
In-Reply-To: <5707CFF6.6090707@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 04/08/2016 05:36 PM, Hannes Frederic Sowa wrote:
> On 08.04.2016 17:25, Bj=C3=B8rn Mork wrote:
>> Hannes Frederic Sowa <hannes@stressinduktion.org> writes:
>>> On Fri, Apr 8, 2016, at 16:18, Bj=C3=B8rn Mork wrote:
>>>> Daniel Borkmann <daniel@iogearbox.net> writes:
>>>>
>>>>>       if (!token)
>>>>>           return -EINVAL;
>>>>> -    if (ipv6_addr_any(token))
>>>>> -        return -EINVAL;
>>>>>       if (dev->flags & (IFF_LOOPBACK | IFF_NOARP))
>>>>>           return -EINVAL;
>>>>
>>>> Not directly related to the patch in question.  It just made me aw=
are of
>>>> this restriction...
>>>>
>>>> I realize that I'm a few years late here, but what's with the IFF_=
NOARP?
>>>> Is that just because we can't do DAD for the token based addresses=
?  How
>>>> is that different from manually configuring the whole address?
>>>
>>> IFF_NOARP is kind of the equivalent to no neighbor discovery. If yo=
u set
>>> a token and never get in a router advertisement you never create a
>>> tokenized ip address, thus the feature is useless.
>>
>> You can get router advertisements with IFF_NOARP. You cannot lookup =
L2
>> addresses, but the L3 prefix info is still as useful as with any oth=
er
>> interface.
>
> Of course router advertisements can be send and received with IFF_NOA=
RP and probably we act on them as usual, as you showed. Looking in the =
source we don't really specify what those flags mean/do for IPv6. So I =
think you can assume that it is in there because of history.
>
> I would absolutely not mind if you remove the limitation for IFF_ARP.

Agreed me neither, the code should be able to handle it as far as I see=
=2E

Thanks,
Daniel
