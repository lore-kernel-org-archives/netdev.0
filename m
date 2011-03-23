From: Steve Calfee <stevecalfee@gmail.com>
Subject: Re: [RFC] usbnet: use eth%d name for known ethernet devices
Date: Wed, 23 Mar 2011 16:38:25 -0700
Message-ID: <4D8A8471.9060904@gmail.com>
References: <4D79F068.2080009@linaro.org> <201103232035.18232.arnd@arndb.de>	<AANLkTim7hPfTv3gDYnh+jGxHBg0OvX=r1FKYoHnH7H_o@mail.gmail.com>	<201103232057.18150.arnd@arndb.de>	<20110323125958.76285c0f.rdunlap@xenotime.net> <8762r9l94h.fsf@erwin.mina86.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Randy Dunlap <rdunlap@xenotime.net>, Arnd Bergmann <arnd@arndb.de>,
	broonie@opensource.wolfsonmicro.com,
	lkml <linux-kernel@vger.kernel.org>,
	Nicolas Pitre <nicolas.pitre@linaro.org>,
	Greg KH <greg@kroah.com>,
	David Brownell <dbrownell@users.sourceforge.net>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>, grant.likely@secretlab.ca,
	Linux USB list <linux-usb@vger.kernel.org>,
	andy.green@linaro.org, netdev@vger.kernel.org,
	Benjamin Herrenschmidt <benh@kernel.crashing.org>,
	roger.quadros@nokia.com,
	Jaswinder Singh <jaswinder.singh@linaro.org>
To: Michal Nazarewicz <mnazarewicz@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <8762r9l94h.fsf@erwin.mina86.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/23/11 16:17, Michal Nazarewicz wrote:
>>>>>>> @@ -97,6 +97,8 @@ struct driver_info {
>>>>>>>
>>>>>>>   #define FLAG_LINK_INTR       0x0800          /* updates link =
(carrier) status */
>>>>>>>
>>>>>>> +#define FLAG_PTP     0x1000          /* maybe use "usb%d" name=
s */
>
>>>>> On Wednesday 23 March 2011 19:46:50 Greg KH wrote:
>>>>>> "PTP"?  What does that stand for?
>
>>>> On Mar 23, 2011 8:36 PM, "Arnd Bergmann"<arnd@arndb.de>  wrote:
>>>>> point-to-point, I'll improve the comment to spell it out when
>>>>> I send the fixed version.
>
>>> On Wednesday 23 March 2011 20:53:13 Micha=C5=82 Nazarewicz wrote:
>>>> I think P2P could be better.
>
>> On Wed, 23 Mar 2011 20:57:18 +0100 Arnd Bergmann wrote:
>>> Yes, good idea.
>
> Randy Dunlap<rdunlap@xenotime.net>  writes:
>> that's peer-to-peer.
>>
>> OTOH, I knew that PTP was point-to-point.
>
> It can be any of that, depending on context.  For me PTP is more like
> Picture Transport Protocol, whereas "2" between two letters is usuall=
y
> "to".
>
Well, my 2 cents, picture transport protocol is so obviously different=20
than flags for network interfaces it does not cause a mental collision.=
=20
However P2P is about to become a huge wifi issue, which definitely is i=
n=20
the network space. So don't confuse things in the near future, don't us=
e=20
P2P.

Maybe a completely different, not so overused flag name would be better=
=2E

Regards, Steve
