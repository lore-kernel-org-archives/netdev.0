From: Gilad Ben-Yossef <gilad@codefidence.com>
Subject: Re: [PATCHv2] IPv4 TCP fails to send window scale option when window
 scale is zero
Date: Thu, 01 Oct 2009 18:12:28 +0200
Message-ID: <4AC4D4EC.1010803@codefidence.com>
References: <4AC478E9.5050605@codefidence.com> <4AC4BD1E.6060706@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Netdev <netdev@vger.kernel.org>, Ori Finkalman <ori@comsleep.com>,
	=?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xenbox.codefidence.com ([92.48.73.16]:50914 "EHLO
	xenbox.codefidence.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752254AbZJAQMc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 1 Oct 2009 12:12:32 -0400
In-Reply-To: <4AC4BD1E.6060706@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:

> Gilad Ben-Yossef a =E9crit :
>  =20
>> From: Ori Finkelman <ori@comsleep.com>
>>
>> diff --git a/net/ipv4/tcp_output.c b/net/ipv4/tcp_output.c
>> index 5200aab..fcd278a 100644
>> --- a/net/ipv4/tcp_output.c
>> +++ b/net/ipv4/tcp_output.c
>> @@ -361,6 +361,7 @@ static inline int tcp_urg_mode(const struct tcp_=
sock
>> *tp)
>> #define OPTION_SACK_ADVERTISE  (1 << 0)
>> #define OPTION_TS              (1 << 1)
>> #define OPTION_MD5             (1 << 2)
>> +#define OPTION_WSCALE          (1 << 3)
>>    =20
>
> I manually applied your patch and tested it.
>
> So far so good, it works well.
>  =20

Glad to hear. Thank you both Eric and Ilpo for the review.
> But you'll need to find correct way to submit a patch so that your ma=
iler doesnt
> mangle the content.
>
> File Documentation/email-clients.txt contains useful tips.
>
>
>  =20
Arrggghh... I thought I have subdued Thunderbird but it tricked me. My=20
prefs.js got re-written somehow. My sincere apologies. This is not my=20
week with MUA.

I also noticed I put the signed-off-by in the wrong place...

Next email is version 3 - same content, hopefully correct formatting.

Thanks again.
Gilad


--=20
Gilad Ben-Yossef
Chief Coffee Drinker & CTO
Codefidence Ltd.

Web:   http://codefidence.com
Cell:  +972-52-8260388
Skype: gilad_codefidence
Tel:   +972-8-9316883 ext. 201
=46ax:   +972-8-9316884
Email: gilad@codefidence.com

Check out our Open Source technology and training blog - http://tuxolog=
y.net

	"Now the world has gone to bed
	 Darkness won't engulf my head
	 I can see by infra-red
	 How I hate the night."

