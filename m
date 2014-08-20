From: Alexander Holler <holler@ahsoftware.de>
Subject: Re: [PATCH] TCP: add option for silent port knocking with integrity
 protection
Date: Wed, 20 Aug 2014 11:07:24 +0200
Message-ID: <53F4654C.10101@ahsoftware.de>
References: <52A75EF8.3010308@in.tum.de>	<20131211.150137.368953964178408437.davem@davemloft.net>	<52A8C8B4.4060109@in.tum.de>	<20131211122637.75b09074@nehalam.linuxnetplumber.net>	<87bo0nulkt.fsf@tassilo.jf.intel.com>	<52A8ECF5.3070604@in.tum.de>	<20131212012317.GL21717@two.firstfloor.org>	<52A98DBF.4090702@appelbaum.net>	<52A9A17F.6050505@in.tum.de>	<1386858864.19078.60.camel@edumazet-glaptop2.roam.corp.google.com>	<53F3A739.4070203@ahsoftware.de> <CAPh34mckmKkRqG7M=37hHRJjBzZ+43BaPnjvpC5sEFnpPqj0aA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Christian Grothoff <grothoff@in.tum.de>,
	Jacob Appelbaum <jacob@appelbaum.net>,
	Andi Kleen <andi@firstfloor.org>,
	Stephen Hemminger <stephen@networkplumber.org>,
	David Miller <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, linux-kernel@vger.kernel.org,
	knock@gnunet.org
To: Hagen Paul Pfeifer <hagen@jauu.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from h1446028.stratoserver.net ([85.214.92.142]:59673 "EHLO
	mail.ahsoftware.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750819AbaHTJHy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Aug 2014 05:07:54 -0400
In-Reply-To: <CAPh34mckmKkRqG7M=37hHRJjBzZ+43BaPnjvpC5sEFnpPqj0aA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am 20.08.2014 10:24, schrieb Hagen Paul Pfeifer:
> On 19 August 2014 21:36, Alexander Holler <holler@ahsoftware.de> wrote:
>
>> It doesn't have to work in every environment and it doesn't have to solve
>> all existing problems in the world. ;)
>>
>> But it enables people to protect a bit more against malicious people or
>> governments.
>>
>> And it is really very easy to use. It took me around half an hour to find
>> the places in openvpn and openssh where I had to add the setsockopt() call
>> and it can be used even easier with preloading libknockify.so.
>>
>> There can be found much more useless options in the kernel. At least I like
>> it and it fits my needs too.
>
> It's not about to add another "useless options", it's about changing
> the major transport protocol. You should probably join the IETF
> tcpm/tcpinc mailing list where TCP stealth is currently actively
> discussed. TCP stealth has problems and you can probably help to
> address them on a *technical level* if you like the mechanism.

As written above, it doesn't have to be perfect and it doesn't have to 
work in every environment.

And I didn't say it is useless. At least that was not my intention (I'm 
no native english speaker). In fact I find it very useful. Such useful 
that I would like it to be already  included in the kernel. It doesn't 
do any harm if disabled, besides a few more lines of (unused) source 
code. Thats why I've written my mail (to support inclusion).

For sure it could be better, but I'm already happy with the current 
imperfect solution which I can use now and not some perfect solution 
which might be available in some years.

Regards,

Alexander Holler
