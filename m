From: =?UTF-8?B?S3J6eXN6dG9mIE9sxJlkemtp?= <ole@ans.pl>
Subject: Re: 2.6.34: Problem with UDP traffic on lo + poll(?)
Date: Tue, 07 Sep 2010 21:20:58 +0200
Message-ID: <4C86909A.8010600@ans.pl>
References: <alpine.LNX.1.10.1009061745280.20113@bizon.gios.gov.pl>	 <1283802132.2585.4.camel@edumazet-laptop>  <4C854737.5040503@ans.pl>	 <1283804955.2585.12.camel@edumazet-laptop> <4C8552B1.8020806@ans.pl>	 <4C855385.7030203@ans.pl>  <4C865C21.5010803@ans.pl> <1283877391.2313.62.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bizon.gios.gov.pl ([195.187.34.71]:50738 "EHLO
	bizon.gios.gov.pl" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757284Ab0IGTVB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Sep 2010 15:21:01 -0400
In-Reply-To: <1283877391.2313.62.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 2010-09-07 18:36, Eric Dumazet wrote:
> Le mardi 07 septembre 2010 =C3=A0 17:37 +0200, Krzysztof Ol=C4=99dzki=
 a =C3=A9crit :
>
>> So far I have found that:
>>
>> 2.6.31.7/2.6.31.12: OK
>> 2.6.32.21: OK
>> 2.6.33-rc1: bad
>> 2.6.33-rc5: bad
>> 2.6.33.7: bad
>> 2.6.34.4/2.6.34.6: bad
>>
>> It looks like the bug must have been introduced in 2.6.33-rc1. There=
 are
>> 8904 commits between 2.6.32 and 2.6.33-rc1, so with ~15 more reboots=
 I
>> should be able to point the problematic commit. I hope. ;)
>>
>>
>
> Hmm, I have a pretty good idea of what the problem is, and will post =
a
> fix soon ;)
>
> Thanks !

Great! So I'm waiting for a patch to test! :)

Best regards,

				Krzysztof Ol=C4=99dzki
