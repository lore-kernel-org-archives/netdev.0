From: Jack Zhang <jack.zhang2011@gmail.com>
Subject: Re: can TCP socket send buffer be over used?
Date: Tue, 3 Aug 2010 18:48:29 -0600
Message-ID: <AANLkTikqTHNmTQL2-QSJZmJ=18CfdZGo41zUE6mKO_PS@mail.gmail.com>
References: <AANLkTi=Ma2yMVbgRnUUB6T1j=rHLb60oAXqCSbM35KgT@mail.gmail.com>
	<4C58B4B4.6010904@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:52254 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757877Ab0HDAsu convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Aug 2010 20:48:50 -0400
Received: by vws3 with SMTP id 3so3610564vws.19
        for <netdev@vger.kernel.org>; Tue, 03 Aug 2010 17:48:49 -0700 (PDT)
In-Reply-To: <4C58B4B4.6010904@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Rick,

Thanks for your reply.

Do you maybe know which part of the source code implements the details
about how much send buffer can actually be used for the data payload?

Thanks a lot!

Jack

On 3 August 2010 18:30, Rick Jones <rick.jones2@hp.com> wrote:
> Jack Zhang wrote:
>>
>> I understand that when the buffer size is set to 128 KB, I actually
>> got a buffer of 256 KB as the kernel doubles the buffer size. I also
>> understand that half the doubled buffer size is used for meta data
>> instead of the actual data to be transferred. So basically the
>> effective buffer sizes for the two examples =A0are just 128 KB and 5=
12
>> KB respectively.
>
> It may not be strictly 1/2. =A0One way to check would be to take a tc=
pdump
> trace on the sending side, and either work-out manually the most the
> connection has outstanding at a time, or run the binary trace through
> something like tcptrace.
>
> rick jones
>
