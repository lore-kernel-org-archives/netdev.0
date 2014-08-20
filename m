From: Alexander Holler <holler@ahsoftware.de>
Subject: Re: [PATCH] TCP: add option for silent port knocking with integrity
 protection
Date: Wed, 20 Aug 2014 12:20:14 +0200
Message-ID: <53F4765E.2040105@ahsoftware.de>
References: <52A75EF8.3010308@in.tum.de>	<20131211.150137.368953964178408437.davem@davemloft.net>	<52A8C8B4.4060109@in.tum.de>	<20131211122637.75b09074@nehalam.linuxnetplumber.net>	<87bo0nulkt.fsf@tassilo.jf.intel.com>	<52A8ECF5.3070604@in.tum.de>	<20131212012317.GL21717@two.firstfloor.org>	<52A98DBF.4090702@appelbaum.net>	<52A9A17F.6050505@in.tum.de>	<1386858864.19078.60.camel@edumazet-glaptop2.roam.corp.google.com>	<53F3A739.4070203@ahsoftware.de>	<CAPh34mckmKkRqG7M=37hHRJjBzZ+43BaPnjvpC5sEFnpPqj0aA@mail.gmail.com>	<53F4654C.10101@ahsoftware.de> <CAPh34mc8eGqLyGrq1AH6AP5yBGnJgePkK03Ys-Zhw9cz9h3Y2g@mail.gmail.com> <53F46EA3.60408@ahsoftware.de>
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
Received: from h1446028.stratoserver.net ([85.214.92.142]:35383 "EHLO
	mail.ahsoftware.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750819AbaHTKVZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 20 Aug 2014 06:21:25 -0400
In-Reply-To: <53F46EA3.60408@ahsoftware.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Am 20.08.2014 11:47, schrieb Alexander Holler:
> Am 20.08.2014 11:28, schrieb Hagen Paul Pfeifer:
>> On 20 August 2014 11:07, Alexander Holler <holler@ahsoftware.de> wrote:
>>
>>> For sure it could be better, but I'm already happy with the current
>>> imperfect solution which I can use now and not some perfect solution
>>> which
>>> might be available in some years.
>>
>> Alexander, to make it clear: we cannot include mechanisms which
>> probably open other (security) issues. This is not how things work
>> out. TCP had so many issues in the past - regarding security,
>> implementation f*ups, etc. pp. It is utterly important that there is
>> no problem with an extension. Please join the discussion ob tcpm if
>> you will drive things forward. That's all what I can say - sorry!
>
> Maybe I first should send a million syn-packets to a box where I've
> enabled that feature. ;)
>
> Anyway, I still think there should be some room for experimental
> features in the kernel. It makes them more visible to possible
> contributors and helps to drive further development.
>
> Not necessarily in my case (as most people, I can't and don't want to
> participate in all parties), but ...

And as I've just read the archives of tcpm, I don't think it would help. 
Jacob Appelbaum already expressed everything I like to use this feature 
for, so most of the time I just had to send a +1 to Jacobs comments, 
which would be somewhat annoying. ;)

Regards,

Alexander Holler
