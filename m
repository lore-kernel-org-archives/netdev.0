From: "=?ISO-8859-1?Q?Miguel_=C1ngel_=C1lvarez?=" <gotzoncabanes@gmail.com>
Subject: Re: qmgr for ixp4xx
Date: Wed, 10 Dec 2008 09:48:20 +0100
Message-ID: <b0438a630812100048v42c4453h353f40c6df494dc4@mail.gmail.com>
References: <b0438a630812021044q31845224s206f3998423289af@mail.gmail.com>
	 <m3zljby7jm.fsf@maximus.localdomain>
	 <b0438a630812050051v6393ae1at40b3669389dd394e@mail.gmail.com>
	 <m31vwmlidh.fsf@maximus.localdomain>
	 <b0438a630812050859jd9fd55ah5fb3608a964f9567@mail.gmail.com>
	 <m3fxl2jx0v.fsf@maximus.localdomain>
	 <20081209164420.GY16037@mail3.prorata.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Krzysztof Halasa" <khc@pm.waw.pl>, netdev@vger.kernel.org
To: "Christian Hohnstaedt" <christian@hohnstaedt.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from yw-out-2324.google.com ([74.125.46.31]:54621 "EHLO
	yw-out-2324.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754272AbYLJIsV convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Dec 2008 03:48:21 -0500
Received: by yw-out-2324.google.com with SMTP id 9so196006ywe.1
        for <netdev@vger.kernel.org>; Wed, 10 Dec 2008 00:48:20 -0800 (PST)
In-Reply-To: <20081209164420.GY16037@mail3.prorata.de>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi

On Tue, Dec 9, 2008 at 5:44 PM, Christian Hohnstaedt
<christian@hohnstaedt.de> wrote:
> On Fri, Dec 05, 2008 at 07:29:36PM +0100, Krzysztof Halasa wrote:
>> "Miguel ?ngel ?lvarez" <gotzoncabanes@gmail.com> writes:
>>
>> > I will check for the 64-queue support patch (thanks Karl). However=
, if
>> > I am not sure they are required. I mean...
>> > - HSS0 uses queues 12-22.
>> > - HSS1 uses queues 0-10.
>> > - That leaves us 10 queues free, doesn't it? Couldn't we use queue=
 11
>> > for eth txreadyq, 23-26 for HSS0 txreadyq, 27-30 for HSS1 txreadyq=
 and
>> > 31 for crypto code (which I do not know?)
>>
>> Ethernet needs 3 queues per port + 1 (465 CPUs can have 3 Ethernet
>> ports), the crypto code probably needs several ones.
>
> Crypto needs 2 queues: 29 and 30.
> The numbers are fixed in the microcode, I think.
>
Thanks for the info, Christian.

Miguel =C1ngel =C1lvarez
