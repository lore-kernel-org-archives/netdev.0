From: Jean-Michel Hautbois <jhautbois@gmail.com>
Subject: Re: TCP communication for raw image transmission
Date: Tue, 3 Jan 2012 08:36:46 +0100
Message-ID: <CAL8zT=htsVAJotATQ5Lqidea5dEqCkZOgTT6t4-fFjjDzcVviw@mail.gmail.com>
References: <CAL8zT=iSiKZfENdtng9gDtuRSuFNn4WZ69uuGapLVVEduFRVyQ@mail.gmail.com>
 <1325519943.2375.31.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
 <CAL8zT=giNe46FYQYxPkbshVfyG-DvCTKS0RLdiN8Kz+e-x-JFw@mail.gmail.com>
 <1325521745.18116.5.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
 <CAL8zT=gbCmtNpw1Lot0P7zB+b_Kw911jhxsXCzO3JOBmMLRcFg@mail.gmail.com>
 <1325523137.18116.11.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
 <1325523178.18116.12.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
 <CAL8zT=gA2pd8wJtBRRLSH_MKXOj3_FzfcXg7v705+8w-xdByLg@mail.gmail.com>
 <1325526085.18116.15.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
 <CAL8zT=jKGYPe+bi44m0ADWzr+h0Hx59oGUYZoYsuu5syQQ-N5g@mail.gmail.com> <CAL8zT=h=mDNiDRVDo=jjcCjkyRGZ79iQiQLT3ZVRLb2PuC2ugg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:51709 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751462Ab2ACHhI convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jan 2012 02:37:08 -0500
Received: by wibhm6 with SMTP id hm6so8867085wib.19
        for <netdev@vger.kernel.org>; Mon, 02 Jan 2012 23:37:07 -0800 (PST)
In-Reply-To: <CAL8zT=h=mDNiDRVDo=jjcCjkyRGZ79iQiQLT3ZVRLb2PuC2ugg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2012/1/2 Jean-Michel Hautbois <jhautbois@gmail.com>:
> 2012/1/2 Jean-Michel Hautbois <jhautbois@gmail.com>:
>> 2012/1/2 Eric Dumazet <eric.dumazet@gmail.com>:
>>> Le lundi 02 janvier 2012 =C3=A0 18:20 +0100, Jean-Michel Hautbois a=
 =C3=A9crit :
>>>
>>>> Here we go...
>>>>
>>>> Recv =C2=A0 Send =C2=A0 =C2=A0Send
>>>> Socket Socket =C2=A0Message =C2=A0Elapsed
>>>> Size =C2=A0 Size =C2=A0 =C2=A0Size =C2=A0 =C2=A0 Time =C2=A0 =C2=A0=
 Throughput
>>>> bytes =C2=A0bytes =C2=A0 bytes =C2=A0 =C2=A0secs. =C2=A0 =C2=A010^=
6bits/sec
>>>>
>>>> =C2=A087380 =C2=A016384 =C2=A016384 =C2=A0 =C2=A060.01 =C2=A0 =C2=A0=
 =C2=A021.79
>>>>
>>>> It is not very good, AFAIK.
>>>> CPU usage is between 17 and 35%.
>>>
>>> Ouch...
>>>
>>> Better find out what is happening before even starting coding
>>> anything...
>>>
>>> checkout "netstat -s" on both sender/receiver
>>

After looking to the results, I can't see really bad values or
anything which would explain such a behaviour...
Maybe is there some limits in the driver ? My board is a leopardboard (=
dm368).
Any idea ?

JM
