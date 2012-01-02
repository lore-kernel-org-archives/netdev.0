From: Jean-Michel Hautbois <jhautbois@gmail.com>
Subject: Re: TCP communication for raw image transmission
Date: Mon, 2 Jan 2012 18:20:21 +0100
Message-ID: <CAL8zT=gA2pd8wJtBRRLSH_MKXOj3_FzfcXg7v705+8w-xdByLg@mail.gmail.com>
References: <CAL8zT=iSiKZfENdtng9gDtuRSuFNn4WZ69uuGapLVVEduFRVyQ@mail.gmail.com>
 <1325519943.2375.31.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
 <CAL8zT=giNe46FYQYxPkbshVfyG-DvCTKS0RLdiN8Kz+e-x-JFw@mail.gmail.com>
 <1325521745.18116.5.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
 <CAL8zT=gbCmtNpw1Lot0P7zB+b_Kw911jhxsXCzO3JOBmMLRcFg@mail.gmail.com>
 <1325523137.18116.11.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC> <1325523178.18116.12.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:54840 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753052Ab2ABRUn convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Jan 2012 12:20:43 -0500
Received: by wibhm6 with SMTP id hm6so8527095wib.19
        for <netdev@vger.kernel.org>; Mon, 02 Jan 2012 09:20:42 -0800 (PST)
In-Reply-To: <1325523178.18116.12.camel@edumazet-HP-Compaq-6005-Pro-SFF-PC>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2012/1/2 Eric Dumazet <eric.dumazet@gmail.com>:
> Le lundi 02 janvier 2012 =C3=A0 17:52 +0100, Eric Dumazet a =C3=A9cri=
t :
>> Le lundi 02 janvier 2012 =C3=A0 17:40 +0100, Jean-Michel Hautbois a =
=C3=A9crit :
>>
>> > Mmmh, using netperf you would like to know what the client (my ARM
>> > board) can do ?
>> > How would you test it ? I can have an ARM board on one side, and t=
he
>> > x86 on the other...
>> >
>>
>> x86> netserver &
>> arm> netperf -H <arm_ip_address> -l 60 -t TCP_STREAM
>>
>
> well it should be :
>
> arm> netperf -H <x86_ip_address> -l 60 -t TCP_STREAM

Here we go...

Recv   Send    Send
Socket Socket  Message  Elapsed
Size   Size    Size     Time     Throughput
bytes  bytes   bytes    secs.    10^6bits/sec

 87380  16384  16384    60.01      21.79

It is not very good, AFAIK.
CPU usage is between 17 and 35%.
