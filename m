From: Gilad Ben-Yossef <gilad@codefidence.com>
Subject: Re: 2.6.32-rc5-mmotm1101 - kernel BUG at net/ipv4/tcp_input.c:3707!
Date: Wed, 04 Nov 2009 08:27:19 +0200
Message-ID: <4AF11EC7.70302@codefidence.com>
References: <5765.1257270611@turing-police.cc.vt.edu> <4AF07024.80103@gmail.com> <4AF08292.7090102@codefidence.com> <Pine.LNX.4.64.0911032330090.3488@melkinkari.cs.Helsinki.FI>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Valdis.Kletnieks@vt.edu, Eric Dumazet <eric.dumazet@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Ori Finkelman <ori@comsleep.com>
To: =?ISO-8859-15?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752131AbZKDG1X@vger.kernel.org>
In-Reply-To: <Pine.LNX.4.64.0911032330090.3488@melkinkari.cs.Helsinki.FI>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Ilpo J=E4rvinen wrote:

> On Tue, 3 Nov 2009, Gilad Ben-Yossef wrote:
>
>  =20
>> Eric Dumazet wrote:
>>
>>    =20
>>> Valdis.Kletnieks@vt.edu a =E9crit :
>>>  =20
>>>      =20
>>>> Seen right after I started 'fetchmail'.  Reproducible - 3 out of 3=
=2E
>>>> I'll bisect this tonight if nobody jumps up and yells they know wh=
at it
>>>> is...
>>>>    =20
>>>>        =20
>> Bah... this is most probably my fault. Sorry about that.
>>
>> Can you please try the patch in the next email?
>>
>> But also, can you please send me the route table in effect when this=
 happened
>> and the fetchmail command line/config (removing any passwords or acc=
ount
>> details of course)? I want to understand better when this happens.
>>    =20
>
> According to the stacktrace, it came from ipv6 side which doesn't hav=
e any=20
> null checking what so ever atm (you only handled ipv4 correctly). ...=
You=20
> should be a bit more careful next time when adding any BUG_ONs...
>  =20
I agree, but for my defense I should add this was not just plain=20
carelessness, I believed
that the dst_entry cannot be NULL at that location. That was obviously=20
wrong. :-(

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

	"The biggest risk you can take it is to take no risk."
		-- Mark Zuckerberg and probably others
