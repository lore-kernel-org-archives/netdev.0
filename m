From: =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
Subject: Re: b43: BCM 4331: MacBook 8,1: No connection after suspend
Date: Sat, 19 Nov 2011 00:08:51 +0100
Message-ID: <CACna6ryw9gC5CnY-ex45JFmQtXRxs8NX9ADkqVZrOj5CCtjiVw@mail.gmail.com>
References: <20111118173242.GA2101@schottelius.org>
	<20111118173921.GB2101@schottelius.org>
	<4EC6B9E9.50204@broadcom.com>
	<4EC6BB5E.4010101@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Nico Schottelius <nico-nospam@schottelius.org>,
	Nico -telmich- Schottelius
	<nico-linux-20111118@schottelius.org>,
	LKML <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"b43-dev@lists.infradead.org" <b43-dev@lists.infradead.org>
To: Arend van Spriel <arend@broadcom.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <4EC6BB5E.4010101@broadcom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2011/11/18 Arend van Spriel <arend@broadcom.com>:
> On 11/18/2011 09:02 PM, Arend van Spriel wrote:
>> On 11/18/2011 06:39 PM, Nico Schottelius wrote:
>>> Nico -telmich- Schottelius [Fri, Nov 18, 2011 at 06:32:42PM +0100]:
>>>> Hello,
>>>>
>>>> new notebook, new problems (*):
>>>
>>> + full dmesg attached.
>>>
>>
>> It seems you are running b43 + bcma. Adding Rafa=C5=82 and friends.
>>
>> Gr. AvS
>
> Hi Rafa=C5=82,
>
> In brcmsmac we reprogram the PCI BAR windows upon resume. Not sure if
> that is done or needed in bcma, but may be worth checking.

Good point.

Please reload b43 *and bcma*. Both drivers. Share your results.

--=20
Rafa=C5=82
