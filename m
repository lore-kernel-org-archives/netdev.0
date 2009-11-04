From: Gilad Ben-Yossef <gilad@codefidence.com>
Subject: Re: 2.6.32-rc5-mmotm1101 - kernel BUG at net/ipv4/tcp_input.c:3707!
Date: Wed, 04 Nov 2009 08:38:01 +0200
Message-ID: <4AF12149.1060305@codefidence.com>
References: <5765.1257270611@turing-police.cc.vt.edu> <4AF07024.80103@gmail.com> <4AF08292.7090102@codefidence.com>            <Pine.LNX.4.64.0911032330090.3488@melkinkari.cs.Helsinki.FI> <7916.1257300093@turing-police.cc.vt.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?windows-1252?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Andrew Morton <akpm@linux-foundation.org>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Ori Finkelman <ori@comsleep.com>
To: Valdis.Kletnieks@vt.edu
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1752580AbZKDGiY@vger.kernel.org>
In-Reply-To: <7916.1257300093@turing-police.cc.vt.edu>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Valdis.Kletnieks@vt.edu wrote:

> On Tue, 03 Nov 2009 23:34:19 +0200, Ilpo J=C3=E2=82=ACrvinen said:
>
>  =20
>> On Tue, 3 Nov 2009, Gilad Ben-Yossef wrote:
>>
>>    =20
>>> Eric Dumazet wrote:
>>>
>>>      =20
>>>> Valdis.Kletnieks@vt.edu a =E9crit :
>>>>  =20
>>>>        =20
>>>>> Seen right after I started 'fetchmail'.  Reproducible - 3 out of =
3.
>>>>> I'll bisect this tonight if nobody jumps up and yells they know w=
hat it
>>>>> is...
>>>>>    =20
>>>>>          =20
>>> Bah... this is most probably my fault. Sorry about that.
>>>
>>> Can you please try the patch in the next email?
>>>      =20
>
> Tried while at home, machine panic'ed.  No netconsole here at the mom=
ent, sorry.
>  =20

Ok, thanks.That is ... strange.

I didn't manage to recreate this here with a simple IPv6 set and netcat
as server client but I will try further, but if there is any way to sen=
d me
the crash location that would be a big help. Thanks.
>  =20
>
> Why was this blowing chunks in the IPv6 when I was making an IPv4 con=
nection
> then? I just noticed that. My fetchmail can't make an IPv6 TCP connec=
tion to
> our IMAP server because the server isn't v6-enabled yet.  And althoug=
h I
> contact our DNS over IPv6, but that's UDP not TCP.
>
>  =20
I don't think the chunk blowing occurred due to the connection to the I=
MAP
server. That codes deals with incoming SYNs. I guess it happened when=20
fetchmail
tried to connect to the local mail daemon and this should be happening=20
over the loopback interface...


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
