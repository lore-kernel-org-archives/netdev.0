From: Gilad Ben-Yossef <gilad@codefidence.com>
Subject: Re: [PATCH RFC] Per route TCP options
Date: Wed, 21 Oct 2009 10:15:14 +0200
Message-ID: <4ADEC312.7090609@codefidence.com>
References: <1256052161-14156-1-git-send-email-gilad@codefidence.com> <4ADDDAFB.5040600@gmail.com> <4ADDE132.3010408@codefidence.com> <Pine.LNX.4.64.0910202151160.22058@melkinkari.cs.Helsinki.FI>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Netdev <netdev@vger.kernel.org>, ori@comsleep.com
To: =?ISO-8859-15?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xenbox.codefidence.com ([92.48.73.16]:56789 "EHLO
	xenbox.codefidence.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752445AbZJUIPO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 21 Oct 2009 04:15:14 -0400
In-Reply-To: <Pine.LNX.4.64.0910202151160.22058@melkinkari.cs.Helsinki.FI>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Ilpo,


Ilpo J=E4rvinen wrote:

>
>> Specifically, I couldn't understand why sysctl_tcp_ecn is documented=
 to be a
>> boolean value, but is initialized to 2 and queried with if (sysctl_t=
cp_ecn =3D=3D
>> 1) so I decided to let it be until I figure it out... ;-)
>>    =20
>
> Ah, I didn't notice that "- BOOLEAN" there so I modified only the=20
> description (some blindness to caps perhaps :-)), did you perhaps rea=
d
> it fully?
>
>  =20
Yes, I did finally. What threw me off was that that=20
TCP_ECN_create_request() were the value if checked as a boolean was=20
inlined in the include file. I've missed that. Thanks for the tip.

At any rate, it means that "noecn" is not a good route option feature,=20
since it is not boolean. I plan to handle those in the next patch set,=20
if the current one is accepted.

Thanks,
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

	"Sorry cannot parse this, its too long to be true  :)"
	  -- Eric Dumazet on netdev mailing list

