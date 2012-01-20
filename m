From: Jean-Michel Hautbois <jhautbois@gmail.com>
Subject: Re: Interpreting perf stat on netperf and netserver
Date: Fri, 20 Jan 2012 08:20:08 +0100
Message-ID: <CAL8zT=iZLorBB0Xn3sQZJe7Ky1ptmA_31FVyDHOCuh-rSicZ8A@mail.gmail.com>
References: <CAL8zT=gNwDDXcbH+hoZApc63ArW2quzHJ1gRrPSxKP7jE04KLw@mail.gmail.com>
 <4F170629.8090307@hp.com> <CAL8zT=jP4Bm=WM0=OLcRgeetzXb0f_ZL0TiDvPAhkbA9UuxpBA@mail.gmail.com>
 <4F1859CA.6000407@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:56665 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750983Ab2ATHUa convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 20 Jan 2012 02:20:30 -0500
Received: by wics10 with SMTP id s10so160764wic.19
        for <netdev@vger.kernel.org>; Thu, 19 Jan 2012 23:20:29 -0800 (PST)
In-Reply-To: <4F1859CA.6000407@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2012/1/19 Rick Jones <rick.jones2@hp.com>:
> On 01/19/2012 12:29 AM, Jean-Michel Hautbois wrote:
>>
>> 2012/1/18 Rick Jones<rick.jones2@hp.com>:
>>>
>>> On 01/18/2012 03:33 AM, Jean-Michel Hautbois wrote:
>>>>
>>>>
>>>> Hi all,
>>>>
>>>> I am currently using netperf/netserver in order to characterize a
>>>> benet emulex network device on a machine with 2 Xeon5670.
>>>> I am using the latest linux kernel from git (3.2.0+).
>>>> I am facing several issues, and I am trying to understand the
>>>> following perf stat launched on netserver :
>>>>
>>>> =C2=A0Performance counter stats for process id '5043':
>>>
>>>
>>>
>>> If you aren't already you may want to gather system-wide data as we=
ll -
>>> not
>>> everything networking is guaranteed to run in the netserver's (or
>>> netperf's)
>>> context.
>>>
>>> Might also be good to include the netperf command line driving that
>>> netserver. =C2=A0That will help folks know if the netserver is rece=
iving data
>>> (_STREAM), sending data (_MAERTS) or both (_RR) (though perhaps tha=
t can
>>> be
>>> gleaned from the routine names in the profile.
>>
>>
>> Well, I am only launching netserver without any parameter.
>
>
> The netperf command line, not netserver :) =C2=A0The netperf command =
line will
> tell us what the netserver was asked to and was presumably doing at t=
he time
> the profile was taken.

I launched it using netperf -H 192.168.2.1 -t UDP_STREAM -f m -- -m 400=
0

The mtu is set to 4096.

JM
