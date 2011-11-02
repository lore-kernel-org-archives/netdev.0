From: Maz The Northener <mazziesaccount@gmail.com>
Subject: Re: [PATCH] IPv6 - support for NLM_F_* flags at IPv6 routing requests
Date: Wed, 2 Nov 2011 08:28:20 +0200
Message-ID: <CANhJrGMeE7qsNBY6Sd2+tUWOezEv=Grc4uoArqAz=Ru4Me8Dsg@mail.gmail.com>
References: <1320157347.11816.3.camel@lakki>
	<20111101224302.6d370068@s6510.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Matti Vaittinen <matti.vaittinen@nsn.com>, davem@davemloft.net,
	netdev@vger.kernel.org
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:37936 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752489Ab1KBG2V convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Nov 2011 02:28:21 -0400
Received: by mail-iy0-f174.google.com with SMTP id e36so712610iag.19
        for <netdev@vger.kernel.org>; Tue, 01 Nov 2011 23:28:20 -0700 (PDT)
In-Reply-To: <20111101224302.6d370068@s6510.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 1, 2011 at 11:43 PM, Stephen Hemminger
<shemminger@vyatta.com> wrote:
> On Tue, 01 Nov 2011 16:22:27 +0200
> Matti Vaittinen <matti.vaittinen@nsn.com> wrote:
>
>>
>> +#define RT6_CANT_CREATE ((int)-1)
>> =A0#define RT6_DEBUG 2
>
> Rather than introduce a new error flag, why not convert the code
> to use the kernel standard PTR_ERR() macros?
> --

Thanks for comment Stephen, I admitt I felt there was something rotten
in adding a new define. And as to why not use PTR_ERR() - I did not
know about such a facility. I'll fix this to be

return ERR_PTR(-ENOENT);

and at calling function check for
if (PTR_ERR(fn) =3D=3D -ENOENT)

I guess that is correct way?

And finally couple of questions about sending patches (I'm a new guy
in this "house" of yours):
Is it Ok to add patch as attachment? I'm having difficulties in using
a client which allows sending plain text.
And is it Ok to create patch against linux 3.1-rc4? I've never used
git, and thus obtaining 3.1-rc4 from kernel.org is the easiest way for
me.

--Matti Vaittinen
