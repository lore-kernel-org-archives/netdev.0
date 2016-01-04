From: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
Subject: Re: net-libertas: Better exception handling in if_spi_host_to_card_worker()
Date: Mon, 4 Jan 2016 12:18:30 +0100
Message-ID: <CACna6rwAVhKX0KnW=BTBDvNe8aaSvQiuMSnMmbQ64Benm50g9w@mail.gmail.com>
References: <566ABCD9.1060404@users.sourceforge.net>
	<5686F0B2.5000000@users.sourceforge.net>
	<56870866.7020000@cogentembedded.com>
	<568785B3.5000905@users.sourceforge.net>
	<alpine.DEB.2.02.1601020914100.2063@localhost6.localdomain6>
	<5687939E.7010701@users.sourceforge.net>
	<5687A2C7.3000704@gmail.com>
	<5687B2BC.8090901@users.sourceforge.net>
	<5688EBAC.5000701@gmail.com>
	<CACna6rzoJLRuTTDi3JjXg1roDbk3HXcBhhe0iOUH9xRaGU5p7A@mail.gmail.com>
	<568A4403.8020701@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: SF Markus Elfring <elfring@users.sourceforge.net>,
	Julia Lawall <julia.lawall@lip6.fr>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	libertas-dev@lists.infradead.org,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>,
	Kalle Valo <kvalo@codeaurora.org>,
	LKML <linux-kernel@vger.kernel.org>,
	kernel-janitors@vger.kernel.org
To: Arend van Spriel <aspriel@gmail.com>
Return-path: <kernel-janitors-owner@vger.kernel.org>
In-Reply-To: <568A4403.8020701@gmail.com>
Sender: kernel-janitors-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 4 January 2016 at 11:05, Arend van Spriel <aspriel@gmail.com> wrote:
> On 03-01-16 16:18, Rafa=C5=82 Mi=C5=82ecki wrote:
>> On 3 January 2016 at 10:36, Arend van Spriel <aspriel@gmail.com> wro=
te:
>>> On 02-01-16 12:21, SF Markus Elfring wrote:
>>>>> Did you look at the resulting assembly code for different target =
architectures?
>>>>
>>>> Not yet. - Which execution system variants would you recommend for
>>>> further comparisons?
>>>
>>> Guess x86{,_64} and arm would be good candidates, ie. CISC vs. RISC=
=2E
>>
>> Oh, don't forget about MIPS with its fancy branches handling. You kn=
ow
>> about it, don't you?
>
> You are asking me, right ;-) ? I have come across my share of MIPS
> platforms here at Broadcom, but I still try to avoid them as much as
> possible.

I was more thinking about author on this patch. But it's indeed an
interesting thing, just to know, how MIPS CPU handles branches ;)

--=20
Rafa=C5=82
--
To unsubscribe from this list: send the line "unsubscribe kernel-janito=
rs" in
the body of a message to majordomo@vger.kernel.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
